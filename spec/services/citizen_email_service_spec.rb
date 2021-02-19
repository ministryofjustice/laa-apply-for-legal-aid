require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe CitizenEmailService do
  let(:simulated_email_address) { Rails.configuration.x.simulated_email_address }
  let(:applicant) { create(:applicant, first_name: 'John', last_name: 'Doe', email: simulated_email_address) }
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let(:application) { create(:application, applicant: applicant, provider: provider) }
  let(:secure_id) { SecureRandom.uuid }
  let(:citizen_url) { "http://www.example.com/citizens/legal_aid_applications/#{secure_id}?locale=en" }

  subject { described_class.new(application) }

  describe '#send_email' do
    let(:mailer_args) do
      [
        application.application_ref,
        applicant.email_address,
        citizen_url,
        applicant.full_name,
        provider.firm.name
      ]
    end
    let(:scheduled_mail_attrs) do
      [
        mailer_klass: NotifyMailer,
        mailer_method: :citizen_start_email,
        legal_aid_application_id: application.id,
        addressee: applicant.email_address,
        arguments: mailer_args
      ]
    end

    before { allow(subject).to receive(:secure_id).and_return(secure_id) }

    it 'schedules and email for immediate delivery' do
      expect(ScheduledMailing).to receive(:send_now!).with(*scheduled_mail_attrs)
      subject.send_email
    end

    it 'notifies the dashboard' do
      expect(subject).to receive(:notify_dashboard)
      subject.send_email
    end
  end
end
