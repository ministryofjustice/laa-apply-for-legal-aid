require 'rails_helper'

RSpec.describe CitizenConfirmationMailer, type: :mailer do
  let(:app_id) { SecureRandom.uuid }
  let(:email) { Faker::Internet.safe_email }
  let(:client_name) { Faker::Name.name }
  let(:citizen_completed_application_template) { Rails.configuration.govuk_notify_templates[:citizen_completed_application] }

  describe '#citizen_start_email' do
    let(:mail) { described_class.citizen_complete_email(app_id, email, client_name) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq(citizen_completed_application_template)
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        client_name: client_name,
        ref_number: app_id
      )
    end
  end
end
