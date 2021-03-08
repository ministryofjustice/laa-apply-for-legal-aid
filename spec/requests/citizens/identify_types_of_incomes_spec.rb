require 'rails_helper'

RSpec.describe Citizens::IdentifyTypesOfIncomesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  let!(:income_types) { create_list :transaction_type, 3, :credit_with_standard_name }
  let(:income_types_without_children) { TransactionType.not_children.where(id: income_types.map(&:id)) }

  describe 'GET /citizens/identify_types_of_income' do
    before do
      get citizens_identify_types_of_income_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the income type labels' do
      income_types_without_children.map(&:label_name).each do |label|
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

    it 'should display an error' do
      subject
      expect(response.body).to match('govuk-error-summary')
      expect(unescaped_response_body).to match(I18n.t('citizens.identify_types_of_incomes.update.none_selected'))
      expect(unescaped_response_body).not_to include('translation missing')
    end

    it 'displays expanded details list' do
      subject
      expect(unescaped_response_body).to match(I18n.t('shared.forms.types_of_income_form.expanded_explanation.heading'))
    end

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'when transaction types selected' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :applicant_entering_means,
               no_credit_transaction_types_selected: true
      end
      let(:transaction_type_ids) { income_types.map(&:id) }

      it 'adds transaction types to the application' do
        expect { subject }.to change { LegalAidApplicationTransactionType.count }.by(income_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(income_types)
      end

      it 'redirects to the cash income step' do
        expect(subject).to redirect_to(citizens_cash_income_path)
      end

      it 'sets no_credit_transaction_types_selected to false' do
        expect { subject }.to change { legal_aid_application.reload.no_credit_transaction_types_selected }.to(false)
      end
    end

    context 'when transaction types selected' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :applicant_entering_means,
               no_credit_transaction_types_selected: true
      end
      let(:transaction_type_ids) { income_types.map(&:id) }

      it 'redirects to the next step' do
        expect(subject).to redirect_to(citizens_cash_income_path)
      end
    end

    context 'when application has transaction types of other kind' do
      let(:other_transaction_type) { create :transaction_type, :debit }
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_applicant,
               :with_non_passported_state_machine,
               :applicant_entering_means,
               transaction_types: [other_transaction_type]
      end

      it 'does not remove existing transaction of other type' do
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

      it 'sets no_credit_transaction_types_selected to true' do
        expect { subject }.to change { legal_aid_application.reload.no_credit_transaction_types_selected }.to(true)
      end

      context 'and application has transactions' do
        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_applicant,
                 :with_non_passported_state_machine,
                 :applicant_entering_means,
                 transaction_types: income_types
        end

        it 'removes transaction types from the application' do
          expect { subject }.to change { LegalAidApplicationTransactionType.count }
            .by(-income_types.length)
        end

        it 'redirects to the next step' do
          expect(subject).to redirect_to(flow_forward_path)
        end
      end
    end

    context 'the wrong transaction type is passed in' do
      let!(:income_types) { create_list :transaction_type, 3, :debit_with_standard_name }
      let(:transaction_type_ids) { income_types.map(&:id) }

      it 'does not add the transaction types' do
        expect { subject }.not_to change { legal_aid_application.transaction_types.count }
      end
    end

    context 'When checking citizen answers' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        legal_aid_application.check_citizen_answers!
        patch citizens_identify_types_of_income_path, params: params
      end

      context 'change to none selected' do
        let(:params) { { legal_aid_application: { none_selected: 'true' } } }

        it 'redirects to the check answers page' do
          expect(response).to redirect_to(citizens_check_answers_path)
        end
      end

      context 'when a different income is selected' do
        let(:params) { { legal_aid_application: { none_selected: 'false' } } }

        it 'redirects to the cash income step' do
          expect(subject).to redirect_to(citizens_cash_income_path)
        end
      end
    end
  end
end
