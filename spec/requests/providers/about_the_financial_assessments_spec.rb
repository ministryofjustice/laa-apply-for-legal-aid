require 'rails_helper'

RSpec.describe 'about financial assessments requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/about_the_financial_assessment' do
    subject { get "/providers/applications/#{application_id}/about_the_financial_assessment" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
        subject
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to the applications page with an error' do
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('About the online financial assessment')
      end
    end
  end

  describe 'POST /providers/applications/:legal_aid_application_id/about_the_financial_assessment/submit' do
    subject { post "/providers/applications/#{application_id}/about_the_financial_assessment/submit" }
    let(:mocked_email_service) { instance_double(CitizenEmailService) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to the applications page without calling the email service' do
          expect(CitizenEmailService).not_to receive(:new)

          subject

          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end

      context 'when the application exists' do
        before do
          allow(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
          allow(mocked_email_service).to receive(:send_email)
        end

        context 'but has already been submitted by the provider' do
          let(:application) { create(:legal_aid_application, :with_applicant, :provider_submitted) }

          it 'raises a state transition error' do
            expect { subject }
              .to raise_error(AASM::InvalidTransition, /Event 'provider_submit' cannot transition from 'provider_submitted/)
          end

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
            .from('initiated').to('provider_submitted')
        end

        it 'sends an e-mail to the citizen' do
          expect(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
          expect(mocked_email_service).to receive(:send_email)

          subject
        end

        it 'display confirmation page after calling the email service' do
          subject
          expect(response.body).to include(application.application_ref)
        end
      end
    end
  end
end
