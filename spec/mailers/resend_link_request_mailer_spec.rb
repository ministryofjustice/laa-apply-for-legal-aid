require 'rails_helper'

RSpec.describe ResendLinkRequestMailer, type: :mailer do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:application_url) { 'https://this_is_a_test.com' }
  let(:mail) do
    described_class.notify(
      legal_aid_application.application_ref,
      legal_aid_application.applicant.email_address,
      application_url,
      legal_aid_application.applicant.full_name
    )
  end

  describe '#notify' do
    it 'sends to correct address' do
      expect(mail.to).to eq([legal_aid_application.applicant.email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end
  end
end
