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

  describe 'GET /citizens/gather_transactions' do
    subject { get citizens_gather_transactions_path }

    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'display retrieving transactions' do
      expect(unescaped_response_body).to include(I18n.t('citizens.gather_transactions.index.retrieving_transactions'))
    end

    it 'does not add its url to history' do
      expect(session[:page_history]).not_to include(citizens_gather_transactions_path)
    end
  end

  describe 'GET /citizens/gather_transactions' do
    let(:worker_id) { SecureRandom.uuid }
    let(:worker) { {} }
    subject { get citizens_gather_transactions_path }

    before do
      expect(ImportBankDataWorker).to receive(:perform_async).with(legal_aid_application.id).and_return(worker_id)
      allow(Sidekiq::Status).to receive(:get_all).and_return(worker)
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      subject
    end

    it 'has successfully retrieved' do
      expect(unescaped_response_body).to include(I18n.t('citizens.gather_transactions.index.heading_1'))
    end

    it 'has reset the session and has no page history' do
      expect(session.keys).not_to include(:page_history)
    end

    context 'background worker is still working' do
      let(:worker) { { 'status' => 'working' } }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not display success message' do
        expect(unescaped_response_body).not_to include(I18n.t('citizens.gather_transactions.index.heading_1'))
      end

      it 'displays a loading message' do
        expect(unescaped_response_body).to include(I18n.t('citizens.gather_transactions.index.retrieving_transactions'))
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
        expect(response.body).to include(I18n.t('citizens.gather_transactions.index.default_error'))
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
