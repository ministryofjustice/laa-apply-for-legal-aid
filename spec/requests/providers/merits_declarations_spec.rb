require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Providers::MeritsDeclarationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, state: :checked_merits_answers }
  let(:provider) { legal_aid_application.provider }

  before do
    legal_aid_application.merits_assessment.update submitted_at: nil
  end

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
          expect(legal_aid_application.reload).to be_generating_reports
        end

        it 'redirects to next page' do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_end_of_application_path(legal_aid_application))
        end

        it 'creates pdf reports' do
          ReportsCreatorWorker.clear
          expect(Reports::ReportsCreator).to receive(:call).with(legal_aid_application)
          subject
          ReportsCreatorWorker.drain
        end

        it 'sets the merits assessment to submitted' do
          subject
          expect(legal_aid_application.reload.summary_state).to eq :submitted
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

        it 'does not set it to submitted' do
          subject
          expect(legal_aid_application.reload.summary_state).to eq :in_progress
        end
      end
    end
  end
end
