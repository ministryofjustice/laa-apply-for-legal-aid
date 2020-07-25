require 'rails_helper'

RSpec.describe 'about financial assessments requests', type: :request do
  let(:application) do
    create(:legal_aid_application,
           :with_proceeding_types,
           :with_applicant_and_address,
           :with_non_passported_state_machine,
           :provider_confirming_applicant_eligibility)
  end
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/about_the_financial_assessment' do
    subject { get "/providers/applications/#{application_id}/about_the_financial_assessment" }

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
        expect(unescaped_response_body).to include(I18n.t('providers.about_the_financial_assessments.show.title'))
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to an error' do
          expect(response).to redirect_to(error_path(:page_not_found))
        end
      end

      context 'when means completed' do
        let(:application) do
          create(
            :legal_aid_application,
            :with_proceeding_types,
            :with_applicant_and_address,
            :with_non_passported_state_machine,
            :provider_assessing_means
          )
        end
        let(:target_path) do
          Flow::KeyPoint.path_for(
            key_point: :start_after_applicant_completes_means,
            journey: :providers,
            legal_aid_application: application
          )
        end

        it 'redirects to start after completed means' do
          expect(response).to redirect_to(target_path)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/about_the_financial_assessment/submit' do
    let(:mocked_email_service) { instance_double(CitizenEmailService) }
    let(:params) { {} }
    subject { patch "/providers/applications/#{application_id}/about_the_financial_assessment", params: params }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to and error page without calling the email service' do
          expect(CitizenEmailService).not_to receive(:new)

          subject

          expect(response).to redirect_to(error_path(:page_not_found))
        end
      end

      context 'when the application exists' do
        before do
          allow(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
          allow(mocked_email_service).to receive(:send_email)
        end

        context 'but has already been submitted by the provider' do
          let(:application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :awaiting_applicant) }

          it 'does not send an email to the citizen' do
            expect(CitizenEmailService).not_to receive(:new)

            begin
              subject
            rescue StandardError
              nil
            end
          end
        end

        it 'changes the application state to "provider_submitted"' do
          expect { subject }
            .to change { application.reload.state }
            .from('provider_confirming_applicant_eligibility').to('awaiting_applicant')
        end

        it 'sends an e-mail to the citizen' do
          expect(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
          expect(mocked_email_service).to receive(:send_email)

          subject
        end

        it 'display confirmation page after calling the email service' do
          subject
          expect(response).to redirect_to providers_legal_aid_application_application_confirmation_path(application_id)
        end
      end

      context 'when save as draft is selected' do
        let(:params) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { application.reload.draft? }.from(false).to(true)
        end

        it 'does not send an email' do
          expect(CitizenEmailService).not_to receive(:new).with(application)
          subject
        end
      end
    end
  end
end
