require 'rails_helper'

RSpec.describe 'providers shared ownership request test', type: :request do
  let!(:legal_aid_application) { create :legal_aid_application }

  describe 'GET #/providers/applications/:legal_aid_application_id/shared_ownership' do
    before do
      get providers_legal_aid_application_shared_ownership_path(legal_aid_application)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the shared ownership page' do
      expect(response).to be_successful
      expect(unescaped_response_body).to match('Does your client own their home with anyone else?')
      expect(unescaped_response_body).to match(LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first)
    end
  end

  describe 'PATCH #/providers/applications/:legal_aid_application_id/shared_ownership' do
    let(:params) do
      {
        legal_aid_application: {
          shared_ownership: shared_ownership
        }
      }
    end

    let(:patch_request) do
      patch providers_legal_aid_application_shared_ownership_path(legal_aid_application), params: params.merge(submit_button)
    end

    context 'Submitted with Continue button' do
      let(:submit_button) do
        {
          continue_button: 'Continue'
        }
      end

      context 'Yes path' do
        let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
        it 'does NOT create an new application record' do
          expect { patch_request }.not_to change { LegalAidApplication.count }
        end

        it 'redirects to the percentage page' do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_percentage_home_path(legal_aid_application)
        end

        it 'update legal_aid_application record' do
          expect(legal_aid_application.shared_ownership).to eq nil
          patch_request
          expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
        end
      end

      context 'No path' do
        let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
        it 'does NOT create an new application record' do
          expect { patch_request }.not_to change { LegalAidApplication.count }
        end

        it 'redirects to the savings and investments page' do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_savings_and_investment_path(legal_aid_application)
        end

        it 'update legal_aid_application record' do
          expect(legal_aid_application.shared_ownership).to eq nil
          patch_request
          expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
        end
      end

      context 'with an invalid param' do
        let(:params) { { legal_aid_application: { shared_ownership: '' } } }
        it 're-renders the form with the validation errors' do
          patch_request
          expect(unescaped_response_body).to include('There is a problem')
          expect(unescaped_response_body).to include('Select yes if you own your home with someone else')
          expect(unescaped_response_body).to include('Does your client own their home with anyone else?')
        end
      end
    end

    context 'submitted with a Save as Draft button' do
      let(:submit_button) do
        {
          draft_button: 'Save as draft'
        }
      end

      context 'Yes path' do
        let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
        it 'does NOT create an new application record' do
          expect { patch_request }.not_to change { LegalAidApplication.count }
        end

        it 'redirects to the percentage page' do
          patch_request
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'update legal_aid_application record' do
          expect(legal_aid_application.shared_ownership).to eq nil
          patch_request
          expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
        end
      end

      context 'No path' do
        let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
        it 'does NOT create an new application record' do
          expect { patch_request }.not_to change { LegalAidApplication.count }
        end

        it 'redirects to the savings and investments page' do
          patch_request
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'update legal_aid_application record' do
          expect(legal_aid_application.shared_ownership).to eq nil
          patch_request
          expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
        end
      end

      context 'with an invalid param' do
        let(:params) { { legal_aid_application: { shared_ownership: '' } } }
        it 're-renders the form with the validation errors' do
          patch_request
          expect(unescaped_response_body).to include('There is a problem')
          expect(unescaped_response_body).to include('Select yes if you own your home with someone else')
          expect(unescaped_response_body).to include('Does your client own their home with anyone else?')
        end
      end
    end
  end
end
