require 'rails_helper'

RSpec.describe UndeliverableEmailAlertMailer, type: :mailer do
  let(:email_address) { 'stephen@stephenrichards.eu' }
  let(:failure_reason) { :permanently_failed }
  let(:mailer) { 'NotifyMailer' }
  let(:mail_method) { 'citizen_start_email' }
  let(:args) { [app_id, email_address, url, applicant_name, provider_firm] }
  let(:app_id) { 'L-H12-3XZ' }
  let(:url) { 'http://localhost/start_my_application/some_secret_id' }
  let(:applicant_name) { 'John Doe' }
  let(:provider_firm) { 'Acme Solicitors' }

  describe '#notify_apply_team' do
    let(:mail) { described_class.notify_apply_team(email_address, failure_reason, mailer, mail_method) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq('e583e4f3-87b9-4fca-8448-82865db41708')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        addressee: email_address,
        environment: :TEST,
        failure_reason: failure_reason,
        mailer_and_method: 'NotifyMailer#citizen_start_email'
      )
    end
  end
end
