require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  describe 'notify' do
    let(:feedback) { create :feedback }
    let(:application) { create :application }
    let(:mail) { described_class.notify(feedback, application.id) }

    it 'uses GovukNotifyMailerJob' do
      expect(described_class.delivery_job).to eq(GovukNotifyMailerJob)
    end

    it 'sends to correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end
  end
end
