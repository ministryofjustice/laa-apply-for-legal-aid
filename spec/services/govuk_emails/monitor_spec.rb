require "rails_helper"

RSpec.describe GovukEmails::Monitor do
  before do
    allow(GovukEmails::Email).to receive(:new).with(scheduled_mailing.govuk_message_id).and_return(response)
    Setting.setting.update!(alert_via_sentry: true)
  end

  let(:response) { instance_double(GovukEmails::Email, status:) }

  describe ".call" do
    subject(:call) { described_class.call(scheduled_mailing.id) }

    shared_examples "a status updater job only" do
      it "does not capture an alert message" do
        expect(AlertManager).not_to receive(:capture_message)
        call
      end

      it "does not schedule an undeliverable alert email" do
        expect { call }.not_to change(ScheduledMailing, :count)
      end

      it "does not enqueue a job to send email" do
        ActiveJob::Base.queue_adapter = :test

        expect { call }.not_to have_enqueued_job

        ActiveJob::Base.queue_adapter = :sidekiq
      end
    end

    context "when on production host" do
      before { allow(HostEnv).to receive(:production?).and_return(true) }

      context "with a provider financial reminder with a \"delivered\" response from govuk notify" do
        let(:scheduled_mailing) { create(:scheduled_mailing, :provider_financial_reminder, :processing) }
        let(:status) { "delivered" }

        it_behaves_like "a status updater job only"

        it "updates the scheduled_mailing record" do
          expect { call }.to change { scheduled_mailing.reload.status }.from("processing").to("delivered")
        end
      end

      context "with a provider financial reminder with a \"permanent-failure\" response from govuk notify" do
        let(:scheduled_mailing) { create(:scheduled_mailing, :provider_financial_reminder, :processing) }

        let(:status) { "permanent-failure" }
        let(:addressee) { scheduled_mailing.addressee }
        let(:id) { scheduled_mailing.id }

        it "updates the scheduled_mailing record" do
          expect { call }.to change { scheduled_mailing.reload.status }.from("processing").to("permanent-failure")
        end

        it "captures alert message" do
          expect(AlertManager).to receive(:capture_message).with("Unable to deliver mail to #{addressee} - ScheduledMailing record #{id}")
          call
        end

        it "creates 1 scheduled_mailing to send alert email to the apply team", :aggregate_failures do
          expect { call }.to change(ScheduledMailing, :count).by(1)

          undelivered_mailing = ScheduledMailing.find_by(mailer_klass: "UndeliverableEmailAlertMailer")

          expect(undelivered_mailing)
            .to have_attributes(
              legal_aid_application_id: scheduled_mailing.legal_aid_application_id,
              mailer_klass: "UndeliverableEmailAlertMailer",
              mailer_method: "notify_apply_team",
              addressee: Rails.configuration.x.support_email_address,
              arguments: [scheduled_mailing.id],
            )

          expect(undelivered_mailing.scheduled_at).to have_been_in_the_past
        end

        it "enqueues job to send email" do
          ActiveJob::Base.queue_adapter = :test

          expect { call }.to have_enqueued_job(ScheduledMailingsDeliveryJob)
                              .on_queue("default")
                              .at(:no_wait)

          ActiveJob::Base.queue_adapter = :sidekiq
        end
      end

      context "with a citizen start email with a \"permanent-failure\" response from govuk notify" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 applicant: build(:applicant, email: "johndoe@example.net"),
                 provider: build(:provider, email: "johndoes-provider@example.net"))
        end

        let(:status) { "permanent-failure" }

        let(:scheduled_mailing) do
          create(:scheduled_mailing,
                 :citizen_start_email,
                 :processing,
                 legal_aid_application_id: legal_aid_application.id,
                 addressee: legal_aid_application.applicant.email)
        end

        let(:expected_provider_args) do
          [
            legal_aid_application.provider.email,
            legal_aid_application.application_ref,
            legal_aid_application.applicant.full_name,
            legal_aid_application.applicant.email,
          ]
        end

        it "marks the citizen start email mailing as cancelled" do
          expect { call }.to change { scheduled_mailing.reload.status }.from("processing").to("cancelled")
        end

        context "when related scheduled reminder exists" do
          let(:citizen_financial_reminder) do
            create(:scheduled_mailing,
                   :citizen_financial_reminder,
                   :waiting,
                   legal_aid_application_id: legal_aid_application.id,
                   addressee: legal_aid_application.applicant.email,
                   scheduled_at: 1.day.from_now)
          end

          before do
            citizen_financial_reminder
          end

          it "marks the related reminder mailing as cancelled" do
            expect { call }.to change { citizen_financial_reminder.reload.status }.from("waiting").to("cancelled")
          end
        end

        it "does not alert" do
          expect(AlertManager).not_to receive(:capture_message)
          call
        end

        it "creates 1 more scheduled_mailings to send alert emails to the provider", :aggregate_failures do
          expect { call }.to change(ScheduledMailing, :count).by(1)

          undelivered_mailings = ScheduledMailing.where(mailer_klass: "UndeliverableEmailAlertMailer")

          expect(undelivered_mailings)
            .to contain_exactly(have_attributes(
                                  legal_aid_application_id: scheduled_mailing.legal_aid_application_id,
                                  mailer_klass: "UndeliverableEmailAlertMailer",
                                  mailer_method: "notify_provider",
                                  addressee: legal_aid_application.provider.email,
                                  arguments: expected_provider_args,
                                ))

          expect(undelivered_mailings.map(&:scheduled_at)).to all(have_been_in_the_past)
        end

        it "enqueues 1 job to send emails" do
          ActiveJob::Base.queue_adapter = :test

          expect { call }.to have_enqueued_job(ScheduledMailingsDeliveryJob)
                              .on_queue("default")
                              .at(:no_wait)
                              .once

          ActiveJob::Base.queue_adapter = :sidekiq
        end
      end
    end

    context "when not on production host with a non-failure" do
      before { allow(HostEnv).to receive(:production?).and_return(false) }

      let(:status) { "sending" }
      let(:scheduled_mailing) { create(:scheduled_mailing, :citizen_start_email, :processing) }

      it_behaves_like "a status updater job only"

      it "updates the scheduled_mailing record" do
        expect { call }.to change { scheduled_mailing.reload.status }.from("processing").to("sending")
      end
    end

    context "when not on production host with a permanent-failure for a citizen start email" do
      before { allow(HostEnv).to receive(:production?).and_return(false) }

      let(:status) { "permanent-failure" }
      let(:scheduled_mailing) { create(:scheduled_mailing, :citizen_start_email, :processing) }

      it_behaves_like "a status updater job only"

      it "updates the scheduled_mailing record" do
        expect { call }.to change { scheduled_mailing.reload.status }.from("processing").to("permanent-failure")
      end
    end
  end
end
