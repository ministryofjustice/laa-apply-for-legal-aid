require 'rails_helper'

RSpec.describe 'check benefits requests', type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }

  describe 'GET /providers/applications/:application_id/check_benefits' do
    let(:get_request) { get "/providers/applications/#{application.id}/check_benefits" }

    it 'returns http success', :vcr do
      get_request
      expect(response).to have_http_status(:ok)
    end

    context 'when the check_benefit_result does not exist' do
      let(:benefit_check_service) { spy(BenefitCheckService) }
      let(:benefit_check_response) do
        {
          benefit_checker_status: Faker::Lorem.word,
          confirmation_ref: SecureRandom.hex
        }
      end

      before do
        allow(BenefitCheckService).to receive(:new).with(application).and_return(benefit_check_service)
      end

      it 'generates a new check_benefit_result' do
        expect(benefit_check_service).to receive(:check_benefits)

        get_request
      end

      it 'creates a check_benefit_result with the right values' do
        expect(benefit_check_service).to receive(:check_benefits).and_return(benefit_check_response)

        get_request
        expect(application.benefit_check_result.result).to eq(benefit_check_response[:benefit_checker_status])
        expect(application.benefit_check_result.dwp_ref).to eq(benefit_check_response[:confirmation_ref])
      end
    end

    context 'when the check_benefit_result already exists' do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

      it 'does not generate a new one' do
        expect(BenefitCheckService).to_not receive(:new)
        get_request
      end
    end
  end
end
