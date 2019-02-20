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
    end
  end
end
