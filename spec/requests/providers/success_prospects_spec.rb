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

      describe 'back link' do
        it 'points to estimated legal costs' do
          expect(response.body).to have_back_link(providers_legal_aid_application_estimated_legal_costs_path(legal_aid_application))
        end
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
          expect(response).to redirect_to(providers_legal_aid_application_merits_declaration_path(legal_aid_application))
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

        context 'invalid params - nothing specified' do
          let(:success_prospect) { nil }
          let(:success_prospect_details) { nil }

          it 'returns http_success' do
            expect(response).to have_http_status(:ok)
          end

          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.merits_assessment.attributes.success_prospect.blank'))
          end
        end

        context 'invalid params - application_purpose missing' do
          let(:success_prospect) { 'marginal' }
          let(:success_prospect_details) { nil }

          it 'returns http_success' do
            expect(response).to have_http_status(:ok)
          end

          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.merits_assessment.attributes.success_prospect_details.blank'))
          end
        end
      end
    end
  end
end
