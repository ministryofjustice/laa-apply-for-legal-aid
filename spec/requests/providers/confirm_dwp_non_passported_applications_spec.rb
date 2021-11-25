require 'rails_helper'

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
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

    describe 'back link' do
      let(:page1) { providers_legal_aid_application_check_provider_answers_path(application) }
      let(:page2) { providers_legal_aid_application_check_benefits_path(application) }

      before do
        login_as application.provider
        get page1
        get page2
        subject
      end

      it 'points to check your answers page' do
        expect(response.body).to have_back_link("#{page1}&back=true")
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
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(double(HMRC::CreateResponsesService, call: %w[one two]))
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

        context 'the employed journey feature flag is not enabled' do
          it 'does not call the HMRC::CreateResponsesService' do
            subject
            expect(HMRC::CreateResponsesService).to_not have_received(:call)
          end
        end

        context 'the employed journey feature flag is enabled' do
          before { Setting.setting.update!(enable_employed_journey: true) }
          context 'the user has employed permissions' do
            before { allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(true) }
            it 'calls the HMRC::CreateResponsesService' do
              subject
              expect(HMRC::CreateResponsesService).to have_received(:call).once
            end
          end

          context 'the user does not have employed permissions' do
            it 'does not call the HMRC::CreateResponsesService' do
              subject
              expect(HMRC::CreateResponsesService).not_to have_received(:call)
            end
          end
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

        it 'keeps the application state to checking applicant details' do
          subject
          expect(application.reload.state).to eq 'checking_applicant_details'
        end

        it 'displays the check_client_details page' do
          subject
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end

        it 'uses the passported state machine' do
          subject
          expect(application.reload.state_machine_proxy.type).to eq 'PassportedStateMachine'
        end

        context 'the employed journey feature flag is not enabled' do
          it 'does not call the HMRC::CreateResponsesService' do
            subject
            expect(HMRC::CreateResponsesService).to_not have_received(:call)
          end
        end

        context 'the employed journey feature flag is enabled' do
          before { Setting.setting.update!(enable_employed_journey: true) }
          context 'the user has employed permissions' do
            before { allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(true) }
            it 'does not call the HMRC::CreateResponsesService' do
              subject
              expect(HMRC::CreateResponsesService).to_not have_received(:call)
            end
          end

          context 'the user has does not have employed permissions' do
            it 'does not call the HMRC::CreateResponsesService' do
              subject
              expect(HMRC::CreateResponsesService).to_not have_received(:call)
            end
          end
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
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'sets the application as draft' do
        subject
        expect(application.reload).to be_draft
      end

      context 'the employed journey feature flag is not enabled' do
        it 'does not call the HMRC::CreateResponsesService' do
          subject
          expect(HMRC::CreateResponsesService).to_not have_received(:call)
        end
      end

      context 'the employed journey feature flag is enabled' do
        before { Setting.setting.update!(enable_employed_journey: true) }
        context 'the user has employed permissions' do
          before { allow_any_instance_of(Provider).to receive(:employment_permissions?).and_return(true) }
          it 'does not call the HMRC::CreateResponsesService' do
            subject
            expect(HMRC::CreateResponsesService).to_not have_received(:call)
          end
        end

        context 'the user has does not have employed permissions' do
          it 'does not call the HMRC::CreateResponsesService' do
            subject
            expect(HMRC::CreateResponsesService).to_not have_received(:call)
          end
        end
      end
    end
  end
end
