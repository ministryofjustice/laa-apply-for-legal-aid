require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SubmitCitizenReminderService, :vcr do
  let(:simulated_email_address) { Rails.configuration.x.simulated_email_address }
  let(:provider) { create :provider, email: simulated_email_address }
  let(:application) { create :application, :with_applicant, provider: provider }
  let(:application_url) { 'http://test.com' }
  let(:url_expiry_date) { (Time.zone.today + 7.days).strftime('%-d %B %Y') }

  subject { described_class.new(application) }

  describe '#send_email' do
    it 'creates two scheduled mailing records' do
      expect { subject.send_email }.to change { ScheduledMailing.count }.by(2)
    end

    context 'sending the email' do
      let(:mail) { SubmitCitizenFinancialReminderMailer.notify_citizen(application.id, simulated_email_address, application_url, application.applicant.full_name, url_expiry_date) }

      it 'sends an email with the right parameters' do
        expect(mail.govuk_notify_personalisation).to eq(
          application_url: application_url,
          ref_number: application.application_ref,
          client_name: application.applicant.full_name,
          expiry_date: url_expiry_date
        )
      end
    end
  end
end
