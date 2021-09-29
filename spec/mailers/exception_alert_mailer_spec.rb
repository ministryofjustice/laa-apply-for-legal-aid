require 'rails_helper'

RSpec.describe ExceptionAlertMailer, type: :mailer do
  let(:environment) { 'production' }
  let(:details) { 'alert details' }
  let(:dummy_email_address) { 'john@example.com' }
  let(:mail) { described_class.notify(environment: environment, details: details, to: dummy_email_address) }

  describe 'notify' do
    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sends to correct address' do
      expect(mail.to).to eq [dummy_email_address]
    end

    it 'has the correct personalisation' do
      expect(mail.govuk_notify_personalisation[:environment]).to eq environment
      expect(mail.govuk_notify_personalisation[:details]).to eq details
    end
  end
end
