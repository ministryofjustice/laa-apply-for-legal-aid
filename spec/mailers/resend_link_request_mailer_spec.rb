require 'rails_helper'

RSpec.describe ResendLinkRequestMailer, type: :mailer do
  describe 'notify' do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:mail) { described_class.notify(legal_aid_application) }

    it 'sends to correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end
  end
end
