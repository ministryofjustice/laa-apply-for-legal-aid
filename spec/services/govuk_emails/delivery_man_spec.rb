require "rails_helper"

ErrorResponseStruct = Struct.new(:code, :body)

RSpec.describe GovukEmails::DeliveryMan do
  subject(:delivery_man) { described_class.call(scheduled_mailing.id) }

  let(:scheduled_mailing) { create(:scheduled_mailing, :waiting) }
  let(:mailer_klass) { scheduled_mailing.mailer_klass }
  let(:mailer_method) { scheduled_mailing.mailer_method }

  describe ".call" do
    context "when the mail is already being processed by another worker" do
      before { scheduled_mailing.update!(status: "processing") }

      it "does not ask if mail eligible for delivery" do
        expect(mailer_klass.constantize).not_to receive(:eligible_for_delivery?)
        delivery_man
      end

      it "does not try to delivery the message" do
        expect(mailer_klass.constantize).not_to receive(mailer_method)
      end
    end

    context "when the mail is still waiting" do
      context "and mail is eligible for delivery" do
        let(:message) { instance_double ActionMailer::MessageDelivery }
        let(:response) { instance_double Mail::Message, govuk_notify_response: govuk_response }
        let(:govuk_response) { instance_double Notifications::Client::ResponseNotification, id: govuk_message_id }
        let(:govuk_message_id) { SecureRandom.uuid }
        let(:time_now) { Time.current }

        before { allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(true) }

        it "delivers the mail" do
          expect(mailer_klass.constantize).to receive(mailer_method).and_return(message)
          expect(message).to receive(:deliver_now!).and_return(response)
          delivery_man
        end

        it "updates the scheduled mail record" do
          travel_to time_now
          allow(mailer_klass.constantize).to receive(mailer_method).and_return(message)
          allow(message).to receive(:deliver_now!).and_return(response)
          delivery_man

          scheduled_mailing.reload
          expect(scheduled_mailing.status).to eq "processing"
          expect(scheduled_mailing.govuk_message_id).to eq govuk_message_id
          expect(scheduled_mailing.sent_at.to_i).to eq time_now.to_i
          travel_back
        end
      end

      context "and the mail cannot be sent with current API key" do
        # this simulates trying to send a message in staging that generates the following error
        # BadRequestError: Can’t send to this recipient using a team-only API key
        let(:scheduled_mailing) { create(:scheduled_mailing, :waiting, legal_aid_application: application) }
        let(:application) do
          create(:legal_aid_application,
                 :with_applicant,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: [:da004],
                 df_options: { DA004: [Time.zone.today, Time.zone.today] })
        end
        let(:response_error_stub) { ErrorResponseStruct.new(400, "BadRequestError: Can’t send to this recipient using a team-only API key") }

        before do
          allow(mailer_klass.constantize).to receive(mailer_method).and_raise(Notifications::Client::BadRequestError.new(response_error_stub))
          allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(true)
        end

        it "cancels the scheduled mail" do
          delivery_man
          expect(scheduled_mailing.reload.status).to eq "cancelled"
        end

        it "is does not get sent to Sentry" do
          expect(Sentry).not_to receive(:capture_exception)
          delivery_man
        end
      end

      context "when the mail is not eligible for delivery" do
        before { allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(false) }

        it "cancels the mail" do
          delivery_man
          scheduled_mailing.reload
          expect(scheduled_mailing.status).to eq "cancelled"
          expect(scheduled_mailing.cancelled_at).to have_been_in_the_past
        end
      end

      context "when the mail raises an exception" do
        let(:message) { instance_double ActionMailer::MessageDelivery, govuk_notify_response: govuk_response }
        let(:govuk_response) { instance_double Notifications::Client::ResponseNotification, id: govuk_message_id }
        let(:govuk_message_id) { SecureRandom.uuid }
        let(:time_now) { Time.current }

        before do
          allow(mailer_klass.constantize).to receive(mailer_method).and_raise("Mailing job failed")
          allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(true)
        end

        it "is captured by AlertManager" do
          expect(AlertManager).to receive(:capture_exception).with(message_contains("Mailing job failed"))
          delivery_man
        end
      end
    end
  end
end
