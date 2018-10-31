require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:app_id) { SecureRandom.uuid }
  let(:email) { Faker::Internet.safe_email }
  let(:client_name) { Faker::Name.name }
  let(:application_url) { "/applications/#{app_id}/citizen/start" }

  describe '#citizen_start_email' do
    let(:mail) { described_class.citizen_start_email(app_id, email, application_url, client_name) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq('570e1b9d-6238-45fd-b75c-96f2f39db8e9')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        application_url: application_url,
        client_name: client_name,
        ref_number: app_id
      )
    end
  end
end
