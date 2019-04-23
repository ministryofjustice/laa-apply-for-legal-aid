require 'rails_helper'

RSpec.describe Providers::SuccessProspectsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/success_prospects' do
    subject { get providers_legal_aid_application_success_prospects_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH providers/success_prospects' do
    subject { patch providers_legal_aid_application_success_prospects_path(legal_aid_application), params: params.merge(submit_button) }
    let(:success_prospect) { 'marginal' }
    let(:success_prospect_details) { Faker::Lorem.paragraph }
    let(:params) do
      {
        merits_assessment: {
          success_prospect: success_prospect.to_s,
          success_prospect_details: success_prospect_details
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.success_prospect).to eq(success_prospect)
          expect(legal_aid_application.merits_assessment.reload.success_prospect_details).to eq(success_prospect_details)
        end

        it 'redirects to the next page' do
          expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.success_prospect).to eq(success_prospect)
          expect(legal_aid_application.merits_assessment.reload.success_prospect_details).to eq(success_prospect_details)
        end

        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'nothing specified' do
          let(:success_prospect) { nil }
          let(:success_prospect_details) { nil }

          it 'redirects to provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'option select that does not require details' do
          let(:success_prospect) { MeritsAssessment.prospect_likely_to_succeed.to_s }
          let(:success_prospect_details) { '' }

          it 'redirects to provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'invalid params - application_purpose missing' do
          let(:success_prospect) { 'marginal' }
          let(:success_prospect_details) { '' }

          it 'renders an error' do
            expect(response).to have_http_status(:ok)
            expect(response.body).to include('id="error_explanation"')
          end
        end
      end
    end
  end
end
