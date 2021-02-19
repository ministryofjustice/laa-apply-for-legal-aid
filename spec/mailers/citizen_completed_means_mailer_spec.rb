require 'rails_helper'

RSpec.describe CitizenCompletedMeansMailer, type: :mailer do
  let(:application) { create :legal_aid_application, :with_everything }
  let(:email) { Faker::Internet.safe_email }
  let(:provider_name) { Faker::Name.name }
  let(:applicant_name) { Faker::Name.name }
  let(:application_url) { '/provider/legal_aid_applications/' }
  let(:client_completed_means_template) { Rails.configuration.govuk_notify_templates[:client_completed_means] }

  describe '#notify_provider' do
    let(:mail) { described_class.notify_provider(application.id, provider_name, applicant_name, application_url, email) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq(client_completed_means_template)
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        email: email,
        provider_name: provider_name,
        applicant_name: applicant_name,
        ref_number: application.application_ref,
        application_url: application_url
      )
    end

    it 'is always eligible for delivery' do
      expect(described_class.eligible_for_delivery?(double(ScheduledMailing))).to be true
    end
  end
end
