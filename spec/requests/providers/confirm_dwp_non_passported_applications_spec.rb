require 'rails_helper'

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications' do
    subject { get "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications" }

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
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications' do
    context 'submitting with Continue button' do
      let(:params) do
        {
          continue_button: 'Continue'
        }
      end

      subject { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: params }

      before do
        login_as application.provider
      end

      context 'the results are correct' do
        let(:params) do
          {
            continue_button: 'Continue',
            binary_choice_form: {
              correct_dwp_result: 'true'
            }
          }
        end

        it 'transitions the application state to applicant details checked' do
          subject
          expect(application.reload.state).to eq 'applicant_details_checked'
        end

        it 'syncs the application' do
          expect(CleanupCapitalAttributes).to receive(:call).with(application)
          subject
        end

        it 'displays the applicant_employed page' do
          subject
          expect(response).to redirect_to providers_legal_aid_application_applicant_employed_index_path(application)
        end

        it 'uses the non-passported state machine' do
          subject
          expect(application.reload.state_machine_proxy.type).to eq 'NonPassportedStateMachine'
        end
      end

      context 'the solicitor wants to override the results' do
        let(:params) do
          {
            continue_button: 'Continue',
            binary_choice_form: {
              correct_dwp_result: 'false'
            }
          }
        end

        before { subject }

        it 'keeps the application state to checking applicant details' do
          expect(application.reload.state).to eq 'checking_applicant_details'
        end

        it 'displays the check_client_details page' do
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end

        it 'uses the passported state machine' do
          expect(application.reload.state_machine_proxy.type).to eq 'PassportedStateMachine'
        end
      end

      context 'the solicitor does not select a radio button' do
        it 'displays an error' do
          subject
          expect(response.body).to include(I18n.t('providers.correct_dwp_results.show.error'))
        end
      end
    end

    context 'submitting with Save As Draft button' do
      let(:params) do
        {
          draft_button: 'Save as draft'
        }
      end

      subject { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: params }

      before do
        login_as application.provider
        subject
      end

      it "redirects provider to provider's applications page" do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'sets the application as draft' do
        expect(application.reload).to be_draft
      end
    end
  end
end
