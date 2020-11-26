require 'rails_helper'

RSpec.describe SubmitApplicationReminderMailer, type: :mailer do
  let(:application) { create :legal_aid_application, :with_applicant, :with_delegated_functions, :with_everything, substantive_application_deadline_on: 10.days.from_now }
  let(:email) { Faker::Internet.safe_email }
  let(:provider_name) { Faker::Name.name }

  describe '#notify_provider' do
    let(:mail) { described_class.notify_provider(application.id, provider_name, email) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      # expect(mail.govuk_notify_template).to eq('c4ac858d-68ae-437b-9353-06e632cd88f2')
      expect(mail.govuk_notify_template).to eq('43de80f4-6a15-4be9-8a29-b3682cea3eee')  # this needs to be changed back and original email template amended
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        email: email,
        provider_name: provider_name,
        ref_number: application.application_ref,
        client_name: application.applicant.full_name,
        delegated_functions_date: application.used_delegated_functions_on.strftime('%d %B %Y'),
        deadline_date: application.substantive_application_deadline_on.strftime('%d %B %Y')
      )
    end
  end
end
