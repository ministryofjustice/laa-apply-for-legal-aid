require 'rails_helper'

RSpec.describe 'citizen accounts request test', type: :request do
  describe 'GET /citizens/account' do
    let!(:applicant) { create :applicant }
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

    before do
      sign_in applicant
      get citizens_accounts_path
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
      expect(unescaped_response_body).to include(bank_name_type)
    end

    it 'display account number' do
      expect(unescaped_response_body).to include(applicant_bank_account.account_number)
    end

    it 'display sort code' do
      expect(unescaped_response_body).to include(applicant_bank_account.sort_code)
    end

    it 'display balance with pound symbol' do
      expect(unescaped_response_body).to include("£#{applicant_bank_account.balance}")
    end
  end
end
