require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_provider_answers' do
    let(:perform_request) { get "/providers/applications/#{application_id}/check_provider_answers" }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to the applications page with an error' do
          perform_request

          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end

      it 'returns success' do
        perform_request

        expect(response).to be_successful
      end

      it 'displays the correct page' do
        perform_request

        expect(unescaped_response_body).to include('Check your answers')
      end

      it 'displays the correct proceeding' do
        perform_request

        expect(unescaped_response_body).to include(application.proceeding_types[0].meaning)
      end

      it 'displays the correct client details' do
        perform_request

        applicant = application.applicant
        address = applicant.addresses[0]

        expect(unescaped_response_body).to include(applicant.first_name)
        expect(unescaped_response_body).to include(applicant.last_name)
        expect(unescaped_response_body).to include(applicant.date_of_birth.to_s)
        expect(unescaped_response_body).to include(applicant.national_insurance_number)
        expect(unescaped_response_body).to include(applicant.email_address)
        expect(unescaped_response_body).to include(address.address_line_one)
        expect(unescaped_response_body).to include(address.city)
        expect(unescaped_response_body).to include(address.postcode)
      end
    end
  end

  describe 'POST /providers/applications/:legal_aid_application_id/check_provider_answers/confirm' do
    let(:perform_request) { post "/providers/applications/#{application_id}/check_provider_answers/confirm" }
    let(:mocked_email_service) { instance_double(CitizenEmailService) }

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects to the applications page without calling the email service' do
          expect(CitizenEmailService).not_to receive(:new)

          perform_request

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
            expect { perform_request }
              .to raise_error(AASM::InvalidTransition, /Event 'provider_submit' cannot transition from 'provider_submitted/)
          end

          it 'does not send an email to the citizen' do
            expect(CitizenEmailService).not_to receive(:new)

            begin
              perform_request
            rescue StandardError
              nil
            end
          end
        end

        it 'changes the application state to "provider_submitted"' do
          expect { perform_request }
            .to change { application.reload.state }
            .from('initiated').to('provider_submitted')
        end

        it 'sends an e-mail to the citizen' do
          expect(CitizenEmailService).to receive(:new).with(application).and_return(mocked_email_service)
          expect(mocked_email_service).to receive(:send_email)

          perform_request
        end

        it 'display confirmation page after calling the email service' do
          perform_request
          follow_redirect!
          expect(response.body).to include('Application completed')
        end
      end
    end
  end
end
