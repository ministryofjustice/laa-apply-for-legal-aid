require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SubmitApplicationReminderService, :vcr do
  let(:smoke_test_email) { Rails.configuration.x.smoke_test_email_address }
  let(:provider) { create :provider, email: smoke_test_email }
  let(:application) { create :application, :with_delegated_functions, :with_substantive_application_deadline_on, provider: provider }

  subject { described_class.new(application) }

  describe '#send_email' do
    it 'sends an email' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubmitApplicationReminderMailer).to receive(:notify_provider)
        .with(application, provider.name, provider.email)
        .and_return(message_delivery).exactly(2).times
      expect(message_delivery).to receive(:deliver_later!).exactly(2).times

      subject.send_email
    end

    context 'sending the email' do
      let(:mail) { SubmitApplicationReminderMailer.notify_provider(application, application.provider.name, provider.email) }
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
