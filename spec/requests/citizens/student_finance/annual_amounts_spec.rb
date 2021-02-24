require 'rails_helper'

RSpec.describe 'annual_amounts', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }

  describe 'GET /citizens/student_finance/annual_amounts' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_student_finances_annual_amount_path
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'contains the correct content' do
      expect(response.body).to include I18n.t('citizens.student_finances.annual_amounts.show.field_set_header')
    end
  end

  describe 'PATCH /citizens/student_finance/annual_amounts' do
    let(:params) do
      {
        irregular_income: {
          amount: amount
        }
      }
    end

    context 'adds an amount' do
      before { get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id) }
      let(:amount) { 2345 }

      it 'displays the outgoing types page' do
        patch citizens_student_finances_annual_amount_path, params: params
        expect(response).to redirect_to(citizens_identify_types_of_outgoing_path)
      end

      it 'creates an irregular income record' do
        expect { patch citizens_student_finances_annual_amount_path, params: params }.to change { IrregularIncome.count }.by(1)
        irregular_income = legal_aid_application.irregular_incomes.first
        expect(irregular_income.amount).to eq 2345
        expect(irregular_income.frequency).to eq 'annual'
        expect(irregular_income.income_type).to eq 'student_loan'
      end

      describe 'update record' do
        before { patch citizens_student_finances_annual_amount_path, params: params }

        context 'update amount' do
          let(:amount) { 5000 }
          it 'updates the same record without creating a new one' do
            expect { patch citizens_student_finances_annual_amount_path, params: params }.to change { IrregularIncome.count }.by(0)
            irregular_income = legal_aid_application.irregular_incomes.first
            expect(irregular_income.amount).to eq 5000
          end
        end
      end
    end

    context 'shows an error when field is empty' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        patch citizens_student_finances_annual_amount_path, params: params
      end
      let(:amount) { '' }

      it 'displays an error' do
        expect(response.body).to include I18n.t('activemodel.errors.models.irregular_income.attributes.amount.blank')
      end
    end
  end
end
