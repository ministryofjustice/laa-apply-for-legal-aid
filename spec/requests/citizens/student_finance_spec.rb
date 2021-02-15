require 'rails_helper'

RSpec.describe 'student_finance', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }

  describe 'GET /citizens/student_finance' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_student_finance_path
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'contains the correct content' do
      expect(response.body).to include('Do you get student finance?')
    end
  end

  describe 'PATCH /citizens/student_finance' do
    let(:params) do
      { legal_aid_application: {
        student_finance: yes_or_no
      } }
    end

    context 'responds YES to student finance' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        patch citizens_student_finance_path, params: params
      end
      let(:yes_or_no) { 'true' }

      it 'displays the annual amounts page' do
        expect(response).to redirect_to(citizens_student_finances_annual_amount_path)
      end

      it 'updates the legal aid application record' do
        expect(legal_aid_application.reload.student_finance).to be true
      end
    end

    context 'responds NO to student finance' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        patch citizens_student_finance_path, params: params
      end
      let(:yes_or_no) { 'false' }

      it 'displays the identify types of outgoing page' do
        expect(response).to redirect_to(citizens_identify_types_of_outgoing_path)
      end

      it 'updates the legal aid application record' do
        expect(legal_aid_application.reload.student_finance).to be false
      end
    end

    context 'No response is entered to student finance' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        patch citizens_student_finance_path, params: params
      end
      let(:yes_or_no) { '' }

      it 'displays an error' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.student_finance.blank'))
      end

      it 'does not update the legal aid application record' do
        expect(legal_aid_application.reload.student_finance).to be nil
      end
    end

    context 'When checking citizen answers' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        legal_aid_application.check_citizen_answers!
        patch citizens_student_finance_path, params: params
      end

      context 'when saying no' do
        let(:yes_or_no) { 'false' }

        it 'should redirect to the check answers page' do
          expect(response).to redirect_to(citizens_check_answers_path)
        end
      end

      context 'when saying yes' do
        let(:yes_or_no) { 'true' }

        it 'should redirect to the annual amounts page' do
          expect(response).to redirect_to(citizens_student_finances_annual_amount_path)
        end
      end
    end
  end
end
