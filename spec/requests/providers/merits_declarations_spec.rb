require 'rails_helper'

RSpec.describe Providers::MeritsDeclarationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/merits_declaration' do
    subject { get providers_legal_aid_application_merits_declaration_path(legal_aid_application) }

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
        expect(response.body).to include('Client declaration')
      end
    end
  end

  describe 'PATCH providers/merits_declaration' do
    subject { patch providers_legal_aid_application_merits_declaration_path(legal_aid_application), params: params.merge(submit_button) }
    let(:client_merits_declaration) { true }
    let(:params) do
      {
        merits_assessment: {
          client_merits_declaration: client_merits_declaration
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.client_merits_declaration).to eq(client_merits_declaration)
        end

        it 'redirects to next page' do
          expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path)
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
