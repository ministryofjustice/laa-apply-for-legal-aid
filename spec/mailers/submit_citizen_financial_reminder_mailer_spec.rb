require 'rails_helper'

RSpec.describe SubmitCitizenFinancialReminderMailer, type: :mailer do
  let(:application) { create :legal_aid_application, :with_applicant, :with_everything, :with_non_passported_state_machine }
  let(:email) { Faker::Internet.safe_email }
  let(:provider_name) { Faker::Name.name }
  let(:application_url) { 'http://test.com' }
  let(:url_expiry_date) { (Time.zone.today + 7.days).strftime('%-d %B %Y') }

  describe '#notify_citizen' do
    let(:mail) { described_class.notify_citizen(application.id, email, application_url, application.applicant.full_name, url_expiry_date) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq('ea0b7443-7200-4abf-8ba8-de0462f9a7b5')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        ref_number: application.application_ref,
        client_name: application.applicant.full_name,
        application_url: application_url,
        expiry_date: (Time.zone.today + 7.days).strftime('%-d %B %Y')
      )
    end
  end

  describe '.eligible_for_delivery?' do
    let(:scheduled_mailing) { create :scheduled_mailing, legal_aid_application: application }
    context 'it is eligible' do
      let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :at_check_provider_answers }
      it 'returns true' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be true
      end
    end

    context 'it is not eligible' do
      let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :at_assessment_submitted }
      it 'returns false' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be false
      end
    end
  end
end
