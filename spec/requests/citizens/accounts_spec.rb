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
      expect(response.body).to include(number_to_currency(applicant_bank_account.balance, unit: '£'))
    end

    it 'adds its url to history' do
      expect(session[:page_history]).to include(citizens_accounts_path)
    end

    it 'has a link to select another bank' do
      expect(response.body).to include(citizens_banks_path)
    end
  end

  describe 'GET /citizens/account/gather' do
    let(:worker_id) { SecureRandom.uuid }
    let(:worker) { {} }
    subject { get gather_citizens_accounts_path }

    before do
      expect(ImportBankDataWorker).to receive(:perform_async).with(legal_aid_application.id).and_return(worker_id)
      allow(Sidekiq::Status).to receive(:get_all).and_return(worker)
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      subject
    end

    it 'redirects to index' do
      expect(response).to redirect_to(citizens_accounts_path)
    end

    it 'has reset the session and has no page history' do
      expect(session.keys).not_to include(:page_history)
    end

    context 'background worker is still working' do
      let(:worker) { { 'status' => 'working' } }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not display account information' do
        expect(unescaped_response_body).to_not include(applicant_bank_account_holder.full_name)
        expect(unescaped_response_body).to_not include('Account')
      end

      it 'displays a loading message' do
        expect(response.body).to include(I18n.t('citizens.accounts.gather.retrieving_transactions'))
      end

      it 'includes the expect HTML for the javascript to work' do
        expect(response.body).to include("<div class=\"worker-waiter\" data-worker-id=\"#{worker_id}\"")
      end
    end

    context 'background worker generated an error' do
      let(:error) { 'something wrong' }
      let(:worker) { { 'status' => 'complete', 'errors' => [error].to_json } }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the default error' do
        expect(response.body).to include(I18n.t('citizens.accounts.gather.default_error'))
      end

      context 'a realistic TrueLayerError is received' do
        let(:truelayer_error_description) { 'The provider service is currently unavailable or experiencing technical difficulties. Please try again later.' }
        let(:error_1) { { bank_data_import: {} } }
        let(:error_2) { { import_account_holders: {} } }
        let(:error_3) { { TrueLayerError: { error_description: truelayer_error_description, error: :provider_error, error_details: {} } } }
        let(:worker) { { 'status' => 'complete', 'errors' => [error_1.to_json, error_2.to_json, error_3.to_json].to_json } }

        it 'displays the TrueLayer error description' do
          expect(response.body).to include('The provider service is currently unavailable or experiencing technical difficulties. Please try again later')
        end
      end
    end
  end
end
