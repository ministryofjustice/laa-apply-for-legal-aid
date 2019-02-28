require 'rails_helper'

RSpec.describe 'IndentifyTypesOfOutgoingsController' do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  let!(:outgoing_types) { create_list :transaction_type, 3, :debit_with_standard_name }

  describe 'GET /citizens/identify_types_of_outgoing' do
    before { get citizens_identify_types_of_outgoing_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the outgoing type labels' do
      outgoing_types.map(&:label_name).each do |label|
        expect(unescaped_response_body).to include(label)
      end
    end
  end

  describe 'PATCH /citizens/identify_types_of_outgoing' do
    let(:flow) do
      Flow::BaseFlowService.flow_service_for(
        :citizens,
        legal_aid_application: legal_aid_application,
        current_step: :identify_types_of_outgoings
      )
    end
    let(:transaction_type_ids) { [] }
    let(:params) do
      {
        legal_aid_application: {
          transaction_type_ids: transaction_type_ids
        }
      }
    end

    subject { patch citizens_identify_types_of_outgoing_path, params: params }

    it 'does not add transaction types to the application' do
      expect { subject }.not_to change { LegalAidApplicationTransactionType.count }
    end

    it 'redirects to the next step' do
      expect(subject).to redirect_to(flow.forward_path)
    end

    context 'when transaction types selected' do
      let(:transaction_type_ids) { outgoing_types.map(&:id) }

      it 'adds transaction types to the application' do
        expect { subject }.to change { LegalAidApplicationTransactionType.count }.by(outgoing_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(outgoing_types)
      end

      it 'should redirect to the next step' do
        expect(subject).to redirect_to(flow.forward_path)
      end
    end
  end
end
