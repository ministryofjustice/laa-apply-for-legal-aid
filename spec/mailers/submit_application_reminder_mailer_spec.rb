require 'rails_helper'

RSpec.describe SubmitApplicationReminderMailer, type: :mailer do
  let(:application) do
    create :legal_aid_application,
           :with_applicant,
           :with_proceeding_types,
           :with_delegated_functions,
           :with_everything,
           delegated_functions_date: 10.days.ago,
           substantive_application_deadline_on: 10.days.from_now
  end
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
      expect(mail.govuk_notify_template).to eq('96e58b6c-83e2-4ae8-be67-028803e98398')
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        email: email,
        provider_name: provider_name,
        ref_number: application.application_ref,
        client_name: application.applicant.full_name,
        delegated_functions_date: application.earliest_delegated_functions_date.strftime('%-d %B %Y'),
        deadline_date: application.substantive_application_deadline_on.strftime('%-d %B %Y')
      )
    end
  end

  describe '.eligible_for_delivery' do
    let(:scheduled_mailing) { create :scheduled_mailing, :due, legal_aid_application_id: application.id }

    context 'ineligible_state' do
      before do
        allow(scheduled_mailing).to receive(:legal_aid_application).and_return(application)
        allow(application).to receive(:state).and_return('use_ccms')
      end
      it 'returns false' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be false
      end
    end

    context 'elgible' do
      it 'returns true' do
        expect(described_class.eligible_for_delivery?(scheduled_mailing)).to be true
      end
    end
  end
end
