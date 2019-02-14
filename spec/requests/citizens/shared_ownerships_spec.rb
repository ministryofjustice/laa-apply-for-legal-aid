require 'rails_helper'

RSpec.describe 'citizen shared ownership request test', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }

  describe 'GET #citizens/shared_ownership' do
    before do
      get citizens_legal_aid_application_path(secure_id)
      get citizens_shared_ownership_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the shared ownership page' do
      expect(response).to be_successful
      expect(unescaped_response_body).to match('Do you own your home with anyone else?')
      expect(unescaped_response_body).to match(LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first)
    end
  end

  describe 'PATCH #citizens/shared_ownership' do
    before do
      get citizens_legal_aid_application_path(secure_id)
    end

    let(:params) do
      {
        legal_aid_application: {
          shared_ownership: shared_ownership
        }
      }
    end

    let(:patch_request) do
      patch citizens_shared_ownership_path, params: params
    end

    context 'Yes path' do
      let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }
      it 'does NOT create an new application record' do
        expect { patch_request }.not_to change { LegalAidApplication.count }
      end

      it 'redirects to the next step in Citizen jouney' do
        patch_request
        expect(response).to redirect_to(citizens_percentage_home_path)
      end

      it 'update legal_aid_application record' do
        expect(legal_aid_application.shared_ownership).to eq nil
        patch_request
        expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
      end

      context 'while checking answers' do
        let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_answers }

        it 'redirects to the next step in flow' do
          patch_request
          expect(response).to redirect_to(citizens_percentage_home_path)
        end
      end
    end

    context 'No path' do
      let!(:shared_ownership) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
      it 'does NOT create an new application record' do
        expect { patch_request }.not_to change { LegalAidApplication.count }
      end

      it 'redirects to the next step in Citizen jouney' do
        patch_request
        expect(response).to redirect_to(citizens_savings_and_investment_path)
      end

      it 'update legal_aid_application record' do
        expect(legal_aid_application.shared_ownership).to eq nil
        patch_request
        expect(legal_aid_application.reload.shared_ownership).to eq shared_ownership
      end

      context 'while checking answers' do
        let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_answers }

        it 'redirects to "restrictions" page' do
          patch_request
          expect(response).to redirect_to(citizens_restrictions_path)
        end
      end
    end

    context 'with an invalid param' do
      let(:params) { { legal_aid_application: { shared_ownership: '' } } }
      it 're-renders the form with the validation errors' do
        patch_request
        expect(unescaped_response_body).to include('There is a problem')
        expect(unescaped_response_body).to include('Select yes if you own your home with someone else')
        expect(unescaped_response_body).to include('Do you own your home with anyone else?')
      end
    end
  end
end
