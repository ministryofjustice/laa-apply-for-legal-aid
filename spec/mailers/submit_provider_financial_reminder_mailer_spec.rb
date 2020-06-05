require 'rails_helper'

RSpec.describe SubmitProviderFinancialReminderMailer, type: :mailer do
  let(:application) { create :legal_aid_application, :with_applicant }
  let(:email) { Faker::Internet.safe_email }
  let(:provider_name) { Faker::Name.name }
  let(:application_url) { 'test' }

  describe '#notify_provider' do
    let(:mail) { described_class.notify_provider(application.id, application_url) }

    it 'sends an email to the correct address' do
      ap application.provider.email
      expect(mail.to).to eq([application.provider.email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq('ec4f423d-498a-4828-ab66-c2453cb42ed3')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        ref_number: application.application_ref,
        client_name: application.applicant.full_name,
        application_url: application_url
      )
    end
  end
end
