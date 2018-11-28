require 'rails_helper'

RSpec.describe 'check benefits requests', type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }
  let(:address_lookup_used) { true }

  describe 'GET /providers/applications/:application_id/check_benefits', :vcr do
    let(:perform_request) { get "/providers/applications/#{application.id}/check_benefits" }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        create :address, applicant: applicant, lookup_used: address_lookup_used
        login_as provider
      end

      it 'returns http success' do
        perform_request
        expect(response).to have_http_status(:ok)
      end

      context "the applicant's address used the lookup service" do
        let(:address_lookup_used) { true }

        it 'has a back link to the address lookup page' do
          perform_request
          expect(unescaped_response_body).to include(edit_providers_legal_aid_application_address_selections_path)
        end
      end

      context "the applicant's address used manual entry" do
        let(:address_lookup_used) { false }

        it 'has a back link to the address lookup page' do
          perform_request
          expect(unescaped_response_body).to include(edit_providers_legal_aid_application_address_path)
        end
      end

      context 'when the check_benefit_result does not exist' do
        it 'generates a new check_benefit_result' do
          expect { perform_request }.to change { BenefitCheckResult.count }.by(1)
        end
      end

      context 'when the check_benefit_result already exists' do
        let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

        it 'does not generate a new one' do
          expect { perform_request }.to_not change { BenefitCheckResult.count }
        end
      end
    end
  end
end
