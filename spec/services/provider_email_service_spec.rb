require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ProviderEmailService do
  let(:smoke_test_email) { Rails.configuration.x.simulated_email_address }
  let(:applicant) { create(:applicant, first_name: 'John', last_name: 'Doe') }
  let(:provider) { create :provider, email: smoke_test_email }
  let(:application) { create(:application, applicant: applicant, provider: provider) }
  let(:application_url) { "http://www.example.com/providers/applications/#{application.id}/client_completed_means?locale=en" }
  subject { described_class.new(application) }

  describe '#send_email' do
    it 'sends an email' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(CitizenCompletedMeansMailer).to receive(:notify_provider)
        .with(application, provider.name, applicant.full_name, application_url, provider.email)
        .and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later!)

      subject.send_email
    end

    context 'sending the email', :vcr do
      let(:mail) { CitizenCompletedMeansMailer.notify_provider(application, provider.name, applicant.full_name, application_url, provider.email) }
      it 'sends an email with the right parameters' do
        expect(mail.govuk_notify_personalisation).to eq(
          email: provider.email,
          provider_name: provider.name,
          applicant_name: applicant.full_name,
          ref_number: application.application_ref,
          application_url: application_url
        )
      end
    end
  end
end
