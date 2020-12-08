require 'rails_helper'

RSpec.describe SubmitProviderFinancialReminderMailer, type: :mailer do
  let(:application) { create :legal_aid_application, :with_applicant }
  let(:email) { Faker::Internet.safe_email }
  let(:provider_name) { Faker::Name.name }
  let(:application_url) { 'test' }

  describe '#notify_provider' do
    let(:mail) { described_class.notify_provider(application.id, application_url) }

    it 'sends an email to the correct address' do
      expect(mail.to).to eq([application.provider.email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      expect(mail.govuk_notify_template).to eq('9843f667-8b11-41c0-9c11-622fffc686ec')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        ref_number: application.application_ref,
        client_name: application.applicant.full_name,
        application_url: application_url
      )
    end
  end

  describe '.eligible_for_delivery?' do
    let(:scheduled_mailing) { create :scheduled_mailing, legal_aid_application: application }
    context 'it is eligible' do
      let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :at_client_completed_means }
      it 'returns true' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be true
      end
    end

    context 'it is not eligible' do
      let(:application) { create :legal_aid_application, :at_assessment_submitted }
      it 'returns false' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be false
      end
    end
  end
end
