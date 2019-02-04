require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_provider_answers' do
    subject { get "/providers/applications/#{application_id}/check_provider_answers" }

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
        expect(unescaped_response_body).to include('Check your answers')
      end

      it 'displays the correct proceeding' do
        expect(unescaped_response_body).to include(application.proceeding_types[0].meaning)
      end

      describe 'back link' do
        it 'points to the select address page' do
          expect(response.body).to have_back_link(reset_providers_legal_aid_application_check_provider_answers_path(application))
        end
      end

      it 'displays the correct client details' do
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

  describe 'POST /providers/applications/:legal_aid_application_id/check_provider_answers/reset' do
    subject { post "/providers/applications/#{application_id}/check_provider_answers/reset" }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
        application.check_your_answers!
        subject
      end

      it 'should redirect back' do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(application))
      end

      it 'should change the stage back to "initialized' do
        subject
        expect(application.reload.initiated?).to be_truthy
      end
    end
  end

  describe 'PATCH  /providers/applications/:legal_aid_application_id/check_provider_answers/continue' do
    context 'Continue' do
      let(:provider) { create(:provider) }
      let(:params) do
        {
          continue_button: 'Continue'
        }
      end

      subject { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: params }

      before do
        login_as provider
        application.check_your_answers!
      end

      it 'redirects to next step' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
      end

      it 'changes the state to "answers_checked"' do
        subject
        expect(application.reload.answers_checked?).to be_truthy
      end

      it 'syncs the application' do
        expect(CleanupCapitalAttributes).to receive(:call).with(application)
        subject
      end
    end

    context 'Save as draft' do
      let(:params) do
        {
          draft_button: 'Save as draft'
        }
      end

      subject { patch "/providers/applications/#{application_id}/check_provider_answers/continue", params: params }

      before do
        login_as create(:provider)
        application.check_your_answers!
        subject
      end

      it 'should redirect to provider legal applications home page' do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'should change the state to "answers_checked"' do
        expect(application.reload.answers_checked?).to be_truthy
      end
    end
  end
end
