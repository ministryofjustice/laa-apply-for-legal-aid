require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SubmitApplicationReminderService, :vcr do
  let(:simulated_email_address) { Rails.configuration.x.simulated_email_address }
  let(:provider) { create :provider, email: simulated_email_address }
  let(:application) do
    create :application,
           :with_applicant,
           :with_proceeding_types,
           :with_delegated_functions,
           :with_substantive_application_deadline_on,
           provider: provider
  end

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
          client_name: application.applicant.full_name,
          delegated_functions_date: application.used_delegated_functions_on.strftime('%-d %B %Y'),
          deadline_date: application.substantive_application_deadline_on.strftime('%-d %B %Y')
        )
      end
    end

    context 'SubmitApplicationReminderMailer already exists' do
      before { subject.send_email }

      it 'adds two new mailer jobs' do
        expect { subject.send_email }.to change { ScheduledMailing.count }.by(2)
      end

      it 'cancels pre-existing jobs' do
        expect(ScheduledMailing.where(cancelled_at: nil).count).to eq(2)
        expect(ScheduledMailing.count).to eq(2)
        subject.send_email
        expect(ScheduledMailing.where.not(cancelled_at: nil).count).to eq(2)
        expect(ScheduledMailing.count).to eq(4)
      end
    end
  end
end
