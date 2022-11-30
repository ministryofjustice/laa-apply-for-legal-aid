require "rails_helper"

RSpec.describe GovukEmails::Monitor do
  let(:scheduled_mailing) { create(:scheduled_mailing, :processing) }
  let(:response) { double GovukEmails::Email, status: }

  before do
    allow(GovukEmails::Email).to receive(:new).with(scheduled_mailing.govuk_message_id).and_return(response)
    Setting.setting.update(alert_via_sentry: true)
  end

  describe ".call" do
    subject { described_class.call(scheduled_mailing.id) }

    context "non-failure response" do
      let(:status) { "delivered" }

      it "updates the scheduled_mailing record" do
        subject
        expect(scheduled_mailing.reload.status).to eq "delivered"
      end
    end

    context "failure response" do
      let(:status) { ScheduledMailing::FAILURE_STATUSES.sample }
      let(:addressee) { scheduled_mailing.addressee }
      let(:id) { scheduled_mailing.id }
      let(:raven_message) { "Unable to deliver mail to #{addressee} - ScheduledMailing record #{id}" }

      it "updates the scheduled_mailing record" do
        subject
        expect(scheduled_mailing.reload.status).to eq status
      end

      context "on production host" do
        before { allow(HostEnv).to receive(:production?).and_return(true) }

        it "captures raven message" do
          expect(AlertManager).to receive(:capture_message).with(raven_message)
          subject
        end

        it "schedules an undeliverable alert email" do
          expect { subject }.to change(ScheduledMailing, :count).by(1)
          undeliverable_alert_mail = ScheduledMailing.order(:created_at).last

          expect(undeliverable_alert_mail.legal_aid_application_id).to eq scheduled_mailing.legal_aid_application_id
          expect(undeliverable_alert_mail.mailer_klass).to eq "UndeliverableEmailAlertMailer"
          expect(undeliverable_alert_mail.mailer_method).to eq "notify_apply_team"
          expect(undeliverable_alert_mail.arguments).to eq [scheduled_mailing.id]
          expect(undeliverable_alert_mail.scheduled_at).to have_been_in_the_past
          expect(undeliverable_alert_mail.addressee).to eq Rails.configuration.x.support_email_address
        end
      end

      context "when the failed email is a citizen start email" do
        let(:applicant) { create(:applicant, email: "johndoe@example.net") }
        let(:provider) { create(:provider) }
        let(:legal_aid_application) { create(:legal_aid_application, applicant:, provider:) }
        let(:scheduled_mailing) do
          create(:scheduled_mailing,
                 :citizen_start_email,
                 :processing,
                 addressee: applicant.email,
                 legal_aid_application_id: legal_aid_application.id)
        end
        let(:mailer_args) do
          [
            provider.email,
            legal_aid_application.application_ref,
            applicant.full_name,
            applicant.email,
          ]
        end

        before { allow(HostEnv).to receive(:production?).and_return(true) }

        it "schedules an email to notify the provider of the failure" do
          expect { subject }.to change(ScheduledMailing, :count).by(2)
        end

        it "uses the undeliverable email alert mailer and the notify_provider method with the right args" do
          subject
          provider_alert_mail = ScheduledMailing.order(:created_at).last

          expect(provider_alert_mail.legal_aid_application_id).to eq scheduled_mailing.legal_aid_application_id
          expect(provider_alert_mail.mailer_klass).to eq "UndeliverableEmailAlertMailer"
          expect(provider_alert_mail.mailer_method).to eq "notify_provider"
          expect(provider_alert_mail.addressee).to eq provider.email
          expect(provider_alert_mail.arguments).to eq mailer_args
          expect(provider_alert_mail.scheduled_at).to have_been_in_the_past
        end
      end

      context "not on production host" do
        before { allow(HostEnv).to receive(:production?).and_return(false) }

        it "does not capture raven message" do
          expect(AlertManager).not_to receive(:capture_message)
          subject
        end

        it "does not schedule an undeliverable alert email" do
          expect { subject }.not_to change(ScheduledMailing, :count)
        end
      end
    end
  end
end
