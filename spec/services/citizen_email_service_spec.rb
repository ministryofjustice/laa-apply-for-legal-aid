require 'rails_helper'

RSpec.describe CitizenEmailService do
  let(:applicant) { create(:applicant, first_name: 'John', last_name: 'Doe', email: 'test@example.com') }
  let(:application) { create(:application, applicant: applicant) }
  let(:secure_id) { SecureRandom.uuid }
  let(:citizen_url) { "http://www.example.com/citizens/legal_aid_applications/#{secure_id}" }

  subject { described_class.new(application) }

  describe '#send_email' do
    it 'sends an email' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(NotifyMailer).to receive(:citizen_start_email)
        .with(application.id, 'test@example.com', citizen_url, 'John Doe')
        .and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later)
      expect(application).to receive(:generate_secure_id).and_return(secure_id)

      subject.send_email
    end
  end
end
