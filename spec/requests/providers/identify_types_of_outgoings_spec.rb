require 'rails_helper'

RSpec.describe Providers::IdentifyTypesOfOutgoingsController do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_applicant }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }
  let!(:outgoing_types) { create_list :transaction_type, 3, :debit_with_standard_name }
  before { login }

  describe 'GET /providers/identify_types_of_outgoing' do
    before { get providers_legal_aid_application_identify_types_of_outgoing_path(legal_aid_application) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the outgoing type labels' do
      outgoing_types.map(&:providers_label_name).each do |label|
        expect(unescaped_response_body).to include(label)
      end
      expect(unescaped_response_body).not_to include('translation missing')
    end

    it 'does not display expanded explanation' do
      expect(unescaped_response_body).not_to match(I18n.t('shared.forms.identify_types_of_outgoings_form.expanded_explanation.heading'))
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/identify_types_of_outgoing' do
    let(:transaction_type_ids) { [] }
    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          transaction_type_ids: transaction_type_ids
        }
      }
    end

    subject do
      patch(
        providers_legal_aid_application_identify_types_of_outgoing_path(legal_aid_application),
        params: params.merge(submit_button)
      )
    end

    it 'does not add transaction types to the application' do
      expect { subject }.not_to change { LegalAidApplicationTransactionType.count }
    end

    it 'should display an error' do
      subject
      expect(response.body).to match('govuk-error-summary')
      expect(unescaped_response_body).to match(I18n.t('generic.none_selected'))
      expect(unescaped_response_body).not_to include('translation missing')
    end

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'when transaction types selected' do
      let(:transaction_type_ids) { outgoing_types.map(&:id) }

      it 'adds transaction types to the application' do
        expect { subject }.to change { LegalAidApplicationTransactionType.count }.by(outgoing_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(outgoing_types)
      end

      it 'should redirect to the next step' do
        expect(subject).to redirect_to(flow_forward_path)
      end

      it 'sets no_debit_transaction_types_selected to false' do
        expect { subject }.to change { legal_aid_application.reload.no_debit_transaction_types_selected }.to(false)
      end

      context 'Form submitted with Save as draft button' do
        let(:transaction_type_ids) { [] }
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it 'redirects to the list of applications' do
          subject
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end
    end

    context 'when application has transaction types of other kind' do
      let(:other_transaction_type) { create :transaction_type, :credit }
      let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [other_transaction_type] }

      it 'does not remove existing transation of other type' do
        expect { subject }.not_to change { legal_aid_application.transaction_types.count }
      end

      it 'does not delete transaction types' do
        expect { subject }.not_to change { TransactionType.count }
      end
    end

    context 'when "none selected" has been selected' do
      let(:params) { { legal_aid_application: { none_selected: 'true' } } }

      it 'does not add transaction types to the application' do
        expect { subject }.not_to change { LegalAidApplicationTransactionType.count }
      end

      it 'redirects to the next step' do
        expect(subject).to redirect_to(flow_forward_path)
      end

      it 'sets no_debit_transaction_types_selected to true' do
        expect { subject }.to change { legal_aid_application.reload.no_debit_transaction_types_selected }.to(true)
      end

      context 'and application has transactions' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: outgoing_types
        end

        it 'removes transaction types from the application' do
          expect { subject }.to change { LegalAidApplicationTransactionType.count }
            .by(-outgoing_types.length)
        end

        it 'redirects to the next step' do
          expect(subject).to redirect_to(flow_forward_path)
        end
      end
    end

    context 'the wrong transaction type is passed in' do
      let!(:income_types) { create_list :transaction_type, 3, :credit_with_standard_name }
      let(:transaction_type_ids) { income_types.map(&:id) }

      it 'does not add the transaction types' do
        expect { subject }.not_to change { legal_aid_application.transaction_types.count }
      end
    end

    context 'when the provider is not authenticated' do
      before { subject }
      let(:login) { nil }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
