require 'rails_helper'

RSpec.describe Providers::ClientCompletedMeansController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
  let(:applicant) { create :applicant, :employed }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/client_completed_means' do
    subject { get providers_legal_aid_application_client_completed_means_path(legal_aid_application) }

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
        expect(response.body).to include('Your client has shared their financial information')
      end

      context 'when the applicant is not employed' do
        let(:applicant) { create :applicant, :not_employed }
        it 'does not include reviewing employment details in action list' do
          expect(response.body).not_to include('Review their employment details')
        end

        it 'includes sorting transactions as first point' do
          expect(response.body).to include('1. Sort their bank transactions into categories')
        end
      end

      context 'when the applicant is employed' do
        it 'includes reviewing employment details in action list' do
          expect(response.body).to include('1. Review their employment details')
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:id/client_completed_means' do
    subject { patch providers_legal_aid_application_client_completed_means_path(legal_aid_application), params: params.merge(submit_button) }
    let(:params) { {} }

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }
        it 'redirects to next page' do
          expect(subject).to redirect_to(providers_legal_aid_application_no_income_summary_path)
        end
      end

      context 'Save as draft button pressed' do
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

      context 'the employed journey feature flag is enabled' do
        before { Setting.setting.update!(enable_employed_journey: true) }
        context 'the user has employed permissions' do
          before { allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(true) }

          let(:submit_button) { { continue_button: 'Continue' } }
          context 'employment income data was received from HMRC' do
            before { allow_any_instance_of(LegalAidApplication).to receive(:hmrc_employment_income?).and_return(true) }
            it 'redirects to the employed income page' do
              subject
              expect(response).to redirect_to(providers_legal_aid_application_employment_income_path(legal_aid_application))
            end
          end

          context 'no employment income data was received from HMRC' do
            before { allow_any_instance_of(LegalAidApplication).to receive(:hmrc_employment_income?).and_return(false) }
            it 'redirects to the no employed income page' do
              subject
              expect(response).to redirect_to(providers_legal_aid_application_no_employment_income_path(legal_aid_application))
            end
          end

          context 'transactions exist, and applicant is not employed' do
            let(:submit_button) { { continue_button: 'Continue' } }
            let(:transaction_type) { create :transaction_type, :salary }
            let(:applicant) { create :applicant, :not_employed }
            let(:legal_aid_application) do
              create :legal_aid_application, applicant: applicant, transaction_types: [transaction_type]
            end
            it 'redirects to next page' do
              expect(subject).to redirect_to(providers_legal_aid_application_income_summary_index_path)
            end
          end
        end
      end
    end
  end
end
