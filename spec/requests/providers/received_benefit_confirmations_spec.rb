require 'rails_helper'

RSpec.describe Providers::ReceivedBenefitConfirmationsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/received_benefit_confirmation' do
    subject { get "/providers/applications/#{application_id}/received_benefit_confirmation" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        subject
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('Which passporting benefit does your client receive?')
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/received_benefit_confirmation' do
    subject { patch "/providers/applications/#{application_id}/received_benefit_confirmation", params: params }
    let(:params) { { dwp_override: { passporting_benefit: nil } } }

    before do
      login_as application.provider
      subject
    end

    context 'validation error' do
      it 'displays error if nothing selected' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Select if your client has received any of these benefits')
      end
    end

    context 'benefit selected' do
      let(:params) { { dwp_override: { passporting_benefit: :universal_credit } } }

      context 'delegated functions' do
        let(:application) do
          create :legal_aid_application,
                 :with_proceeding_types,
                 :with_applicant_and_address,
                 used_delegated_functions: true
        end

        it 'continue to the substantive applications page' do
          expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(application))
        end
      end

      context 'no delegated functions' do
        it 'continue to the capital introductions page' do
          expect(response).to redirect_to(providers_legal_aid_application_capital_introduction_path(application))
        end
      end
    end

    context 'none of these selected' do
      let(:params) { { dwp_override: { passporting_benefit: :none_selected } } }

      it 'continue to the applicant details page' do
        expect(response).to redirect_to(providers_legal_aid_application_applicant_employed_index_path(application))
      end
    end
  end
end
