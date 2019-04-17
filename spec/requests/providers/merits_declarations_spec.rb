require 'rails_helper'

RSpec.describe Providers::MeritsDeclarationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, state: :checked_merits_answers }
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
        expect(response.body).to include('Declaration')
        expect(unescaped_response_body).to include(legal_aid_application.applicant.full_name)
      end
    end
  end

  describe 'PATCH providers/merits_declaration' do
    subject { patch providers_legal_aid_application_merits_declaration_path(legal_aid_application), params: submit_button }

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'updates the record' do
          legal_aid_application.create_merits_assessment!
          expect { subject }.to change { legal_aid_application.merits_assessment.reload.submitted_at }.from(nil)
        end

        it 'redirects to next page' do
          subject
          expect(response.body).to eq(Flow::Flows::ProviderMerits::STEPS[:placeholder_end_merits][:path])
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          subject
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
