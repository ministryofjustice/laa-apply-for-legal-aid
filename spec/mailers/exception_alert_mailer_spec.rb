require 'rails_helper'

RSpec.describe ExceptionAlertMailer, type: :mailer do
  let(:environment) { 'production' }
  let(:details) { 'alert details' }
  let(:to) { SlackAlerter::SLACK_CHANNEL_EMAIL }
  let(:mail) { described_class.notify(environment: environment, details: details, to: to) }

  describe 'notify' do
    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sends to correct address' do
      expect(mail.to).to eq([SlackAlerter::SLACK_CHANNEL_EMAIL])
    end

    it 'has the correct personalisation' do
      expect(mail.govuk_notify_personalisation[:environment]).to eq environment
      expect(mail.govuk_notify_personalisation[:details]).to eq details
    end
  end
end
