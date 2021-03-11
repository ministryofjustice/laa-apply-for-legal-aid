require 'rails_helper'

RSpec.describe GovukEmails::DeliveryMan do
  let(:scheduled_mailing) { create :scheduled_mailing, :waiting }
  let(:mailer_klass) { scheduled_mailing.mailer_klass }
  let(:mailer_method) { scheduled_mailing.mailer_method }

  subject { described_class.call(scheduled_mailing.id) }

  describe '.call' do
    context 'mail is already being processed by another worker' do
      before { scheduled_mailing.update!(status: 'processing') }

      it 'does not ask if mail eligible for delivery' do
        expect(mailer_klass.constantize).not_to receive(:eligible_for_delivery?)
        subject
      end

      it 'does not try to delivery the message' do
        expect(mailer_klass.constantize).not_to receive(mailer_method)
      end
    end

    context 'mail is still wating' do
      context 'mail is eligible for delivery' do
        let(:message) { double 'MailMessage', govuk_notify_response: govuk_response }
        let(:govuk_response) { double 'GovukResponse', id: govuk_message_id }
        let(:govuk_message_id) { SecureRandom.uuid }
        let(:time_now) { Time.current }

        before { allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(true) }

        it 'delivers the mail' do
          expect(mailer_klass.constantize).to receive(mailer_method).and_return(message)
          expect(message).to receive(:deliver_now!).and_return(message)
          subject
        end

        it 'updates the scheduled mail record' do
          travel_to time_now
          allow(mailer_klass.constantize).to receive(mailer_method).and_return(message)
          allow(message).to receive(:deliver_now!).and_return(message)
          subject

          scheduled_mailing.reload
          expect(scheduled_mailing.status).to eq 'processing'
          expect(scheduled_mailing.govuk_message_id).to eq govuk_message_id
          expect(scheduled_mailing.sent_at.to_i).to eq time_now.to_i
          travel_back
        end
      end

      context 'mail is not eligible for delivery' do
        before { allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(false) }

        it 'cancels the mail' do
          subject
          scheduled_mailing.reload
          expect(scheduled_mailing.status).to eq 'cancelled'
          expect(scheduled_mailing.cancelled_at).to have_been_in_the_past
        end
      end

      context 'mail raises an exception' do
        let(:message) { double 'MailMessage', govuk_notify_response: govuk_response }
        let(:govuk_response) { double 'GovukResponse', id: govuk_message_id }
        let(:govuk_message_id) { SecureRandom.uuid }
        let(:time_now) { Time.current }

        before do
          allow(mailer_klass.constantize).to receive(mailer_method).and_raise('Mailing job failed')
          allow(mailer_klass.constantize).to receive(:eligible_for_delivery?).and_return(true)
        end

        it 'is captured by Sentry' do
          expect(Sentry).to receive(:capture_exception).with(message_contains('Mailing job failed'))
          subject
        end
      end
    end
  end
end
