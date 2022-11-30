require "rails_helper"

RSpec.describe UndeliverableEmailAlertMailer do
  let(:applicant) { create(:applicant, first_name: "John", last_name: "Doe", email: "johndoe@email.com") }
  let(:provider) { create(:provider) }
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:failure_reason) { "permanently-failed" }
  let(:mailer) { "NotifyMailer" }
  let(:mail_method) { "citizen_start_email" }
  let(:args) { [] }
  let(:app_id) { "L-H12-3XZ" }
  let(:url) { "http://localhost/start_my_application/some_secret_id" }
  let(:scheduled_mailing) do
    create(:scheduled_mailing,
           :citizen_start_email,
           :failed,
           addressee: applicant.email,
           legal_aid_application_id: legal_aid_application.id)
  end

  describe "#notify_apply_team" do
    let(:mail) { described_class.notify_apply_team(scheduled_mailing.id) }

    it "sends an email to the correct address" do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it "is a govuk_notify delivery" do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it "sets the correct template" do
      expect(mail.govuk_notify_template).to eq("8977dba0-7f06-4180-8ae8-11f630be8849")
    end

    it "has the right personalisation" do
      expect(mail.govuk_notify_personalisation).to eq(
        email_address: scheduled_mailing.addressee,
        failure_reason: scheduled_mailing.status,
        mailer_and_method: "NotifyMailer#citizen_start_email",
        mail_params: scheduled_mailing.arguments,
      )
    end
  end

  describe "#notify_provider" do
    let(:mailer_args) do
      [
        provider.email,
        legal_aid_application.application_ref,
        applicant.full_name,
        applicant.email,
      ]
    end
    let(:mail) { described_class.notify_provider(*mailer_args) }

    it "sends an email to the correct provider email address" do
      expect(mail.to).to eq([provider.email])
    end

    it "is a govuk_notify delivery" do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it "sets the correct template" do
      expect(mail.govuk_notify_template).to eq("f4a1139e-ac74-4a8b-8ecf-bfa3de272236")
    end

    it "has the right personalisation" do
      expect(mail.govuk_notify_personalisation).to eq(
        ref_number: legal_aid_application.application_ref,
        applicant_name: applicant.full_name,
        applicant_email: applicant.email,
      )
    end
  end
end
