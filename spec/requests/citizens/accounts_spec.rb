require 'rails_helper'

RSpec.describe 'citizen accounts request', type: :request do
  include ActionView::Helpers::NumberHelper

  let!(:applicant) { create :applicant }
  let!(:legal_aid_application) { create :legal_aid_application, :with_transaction_period, :with_non_passported_state_machine, :awaiting_applicant, applicant: applicant }
  let(:addresses) do
    [{ address: Faker::Address.building_number,
       city: Faker::Address.city,
       zip: Faker::Address.zip }]
  end
  let!(:applicant_bank_provider) { create(:bank_provider, applicant_id: applicant.id) }
  let!(:applicant_bank_account_holder) do
    create(:bank_account_holder, bank_provider_id: applicant_bank_provider.id,
                                 addresses: addresses)
  end
  let!(:applicant_bank_account) do
    create(:bank_account, bank_provider_id: applicant_bank_provider.id, currency: 'GBP')
  end

  let(:page_history_service) { PageHistoryService.new(page_history_id: session['page_history_id']) }

  describe 'GET /citizens/account' do
    subject { get citizens_accounts_path }

    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'display account holder name' do
      expect(unescaped_response_body).to include(applicant_bank_account_holder.full_name)
    end

    it 'display first account holder address' do
      expect(unescaped_response_body).to include(addresses.first.values.join(', '))
    end

    it 'display bank name and bank account type' do
      bank_name_type = "#{applicant_bank_provider.name} #{applicant_bank_account.name}"
      expect(response.body).to include(bank_name_type)
    end

    it 'display account number' do
      expect(response.body).to include(applicant_bank_account.account_number)
    end

    it 'display sort code' do
      expect(response.body).to include(applicant_bank_account.sort_code)
    end

    it 'display balance with pound symbol' do
      expect(response.body).to include(gds_number_to_currency(applicant_bank_account.balance, unit: '£'))
    end

    it 'adds its url to history' do
      expect(page_history_service.read).to include(citizens_accounts_path)
    end

    it 'has a link to select another bank' do
      expect(response.body).to include(citizens_banks_path)
    end
  end
end
