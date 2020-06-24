require 'rails_helper'

RSpec.describe 'student_finance', type: :request do

  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }



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
    # before do
    #   get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
    # end

    let(:params) do
      { legal_aid_application: {
          student_finances: yes_or_no
      } }
    end
    context 'responds YES to student finance' do
      before do
        get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
        patch citizens_student_finance_path, params: params
      end
      let(:yes_or_no) {'true'}

      it 'is successful' do
        expect(response).to be_successful
      end

      it 'displays the annual amounts page' do
        expect(response).to redirect_to(citizens_student_finances_annual_amount_path)
      end

    end
  end

end