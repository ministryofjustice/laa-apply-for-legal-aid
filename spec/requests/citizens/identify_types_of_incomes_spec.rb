require 'rails_helper'

RSpec.describe 'IndentifyTypesOfIncomesController' do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  let!(:income_types) { create_list :transaction_type, 3, :credit_with_standard_name }

  describe 'GET /citizens/identify_types_of_income' do
    before { get citizens_identify_types_of_income_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the income type labels' do
      income_types.map(&:label_name).each do |label|
        expect(unescaped_response_body).to include(label)
      end
      expect(unescaped_response_body).not_to include('translation missing')
    end
  end

  describe 'PATCH /citizens/identify_types_of_income' do
    let(:transaction_type_ids) { [] }
    let(:params) do
      {
        legal_aid_application: {
          transaction_type_ids: transaction_type_ids
        }
      }
    end
    subject { patch citizens_identify_types_of_income_path, params: params }

    it 'does not add transaction types to the application' do
      expect { subject }.not_to change { LegalAidApplicationTransactionType.count }
    end

    it 'redirects to the next step' do
      expect(subject).to redirect_to(flow_forward_path)
    end

    context 'when transaction types selected' do
      let(:transaction_type_ids) { income_types.map(&:id) }

      it 'adds transaction types to the application' do
        expect { subject }.to change { LegalAidApplicationTransactionType.count }.by(income_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(income_types)
      end

      it 'should redirect to the next step' do
        expect(subject).to redirect_to(flow_forward_path)
      end
    end
  end
end
