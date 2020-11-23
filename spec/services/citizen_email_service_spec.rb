require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe CitizenEmailService do
  let(:smoke_test_email) { Rails.configuration.x.simulated_email_address }
  let(:applicant) { create(:applicant, first_name: 'John', last_name: 'Doe', email: smoke_test_email) }
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let(:application) { create(:application, applicant: applicant, provider: provider) }
  let(:secure_id) { SecureRandom.uuid }
  let(:citizen_url) { "http://www.example.com/citizens/legal_aid_applications/#{secure_id}?locale=en" }

  subject { described_class.new(application) }

  describe '#send_email' do
    it 'sends an email' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(NotifyMailer).to receive(:citizen_start_email)
        .with(application.application_ref, applicant.email, citizen_url, 'John Doe', provider.firm.name)
        .and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later!)
      expect(application).to receive(:generate_secure_id).and_return(secure_id)
      expect_any_instance_of(DashboardEventHandler).to receive(:applicant_emailed)

      subject.send_email
    end

    context 'sending the email', :vcr do
      before do
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.clear
        allow_any_instance_of(Notifications::Client).to receive(:get_notification).and_return(OpenStruct.new(status: 'delivered'))
        allow_any_instance_of(DashboardEventHandler).to receive(:call).and_return(double(DashboardEventHandler))
      end
      it 'sends an email with the right parameters' do
        expect_any_instance_of(NotifyMailer)
          .to receive(:set_personalisation)
          .with(hash_including(ref_number: application.application_ref))
          .and_call_original
        subject.send_email
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
      end
    end
  end
end
