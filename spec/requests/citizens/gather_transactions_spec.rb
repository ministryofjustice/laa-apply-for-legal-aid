require 'rails_helper'

RSpec.describe 'citizen accounts request', type: :request do
  include ActionView::Helpers::NumberHelper

  let!(:applicant) { create :applicant }
  let!(:legal_aid_application) { create :legal_aid_application, :with_transaction_period, :with_non_passported_state_machine, :awaiting_applicant, applicant: applicant }
  let!(:applicant_bank_provider) { create(:bank_provider, applicant_id: applicant.id) }
  let!(:applicant_bank_account_holder) do
    create(:bank_account_holder, bank_provider_id: applicant_bank_provider.id,
                                 addresses:)
  end
  let(:addresses) do
    [{ address: Faker::Address.building_number,
       city: Faker::Address.city,
       zip: Faker::Address.zip }]
  end
  let(:page_history_service) { PageHistoryService.new(page_history_id: session['page_history_id']) }

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
      expect(page_history_service.read).to eq nil
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

    it 'returns http_success' do
      expect(response).to have_http_status(:ok)
    end

    it 'has reset the page history' do
      expect(page_history_service.read).to eq nil
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
        expect(response.body).to include(I18n.t('citizens.gather_transactions.index.retrieving_transactions'))
      end

      it 'includes the expect HTML for the javascript to work' do
        expect(response.body).to include("<div class=\"worker-waiter\" data-worker-id=\"#{worker_id}\"")
      end
    end

    context 'background worker generated an error' do
      let(:error) { true_layer_error }
      let(:worker) { { 'status' => 'complete', 'errors' => true_layer_error.to_json } }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the default error' do
        expect(response.body).to include(I18n.t('true_layer_errors.headings.provider_error'))
      end

      def true_layer_error
        [
          'bank_data_import',
          'import_account_holders',
          true_layer_error_hash.to_json
        ]
      end

      def true_layer_error_hash
        {
          'TrueLayerError' => {
            'error_description' => 'The provider service is currently unavailable or experiencing technical difficulties. Please try again later.',
            'error' => 'provider_error',
            'error_details' => {},
          },
        }
      end
    end
  end
end
