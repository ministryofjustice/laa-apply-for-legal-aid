require 'rails_helper'

RSpec.describe ResendLinkRequestMailer, type: :mailer do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:mail) { described_class.notify(legal_aid_application, legal_aid_application.applicant) }

  it 'uses GovukNotifyMailerJob' do
    expect(described_class.delivery_job).to eq(GovukNotifyMailerJob)
  end

  describe '#notify' do
    it 'sends to correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end
  end
end
