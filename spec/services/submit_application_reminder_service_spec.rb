require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SubmitApplicationReminderService, :vcr do
  let(:smoke_test_email) { Rails.configuration.x.smoke_test_email_address }
  let(:provider) { create :provider, email: smoke_test_email }
  let(:application) { create :application, :with_applicant, :with_delegated_functions, :with_substantive_application_deadline_on, provider: provider }

  subject { described_class.new(application) }

  describe '#send_email' do
    it 'creates two scheduled mailing records' do
      expect { subject.send_email }.to change { ScheduledMailing.count }.by(2)
    end

    context 'sending the email' do
      let(:mail) { SubmitApplicationReminderMailer.notify_provider(application.id, application.provider.name, provider.email) }
      it 'sends an email with the right parameters' do
        expect(mail.govuk_notify_personalisation).to eq(
          email: provider.email,
          provider_name: provider.name,
          ref_number: application.application_ref,
          delegated_functions_date: application.used_delegated_functions_on,
          deadline_date: application.substantive_application_deadline_on
        )
      end
    end
  end
end
