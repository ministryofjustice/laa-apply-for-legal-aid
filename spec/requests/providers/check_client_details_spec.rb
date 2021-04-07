require 'rails_helper'

RSpec.describe Providers::CheckClientDetailsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_client_details' do
    subject { get "/providers/applications/#{application_id}/check_client_details" }

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

      it 'displays the applicant\'s full name' do
        full_name = "#{application.applicant.first_name} #{application.applicant.last_name}"
        expect(unescaped_response_body).to include(full_name)
      end

      it 'displays the applicant date of birth in the required format' do
        dob_formatted = application.applicant.date_of_birth.strftime('%e %B %Y')
        expect(unescaped_response_body).to include(dob_formatted)
      end

      it 'displays the applicant national insurance number with 2 digit spacing' do
        ni_number = application.applicant.national_insurance_number.gsub(/(.{2})(?=.)/, '\1 \2')
        expect(unescaped_response_body).to include(ni_number)
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/check_client_details' do
    subject { patch "/providers/applications/#{application_id}/check_client_details", params: params }

    before do
      login_as application.provider
      subject
    end

    context 'correct client details' do
      let(:params) { { binary_choice_form: { check_client_details: 'true' } } }

      it 'continue to the received benefit confirmations page' do
        expect(response).to redirect_to(providers_legal_aid_application_received_benefit_confirmation_path(application))
      end
    end

    context 'incorrect client details' do
      let(:params) { { binary_choice_form: { check_client_details: 'false' } } }

      it 'continue to the applicant details page' do
        expect(response).to redirect_to(providers_legal_aid_application_applicant_details_path(application))
      end
    end

    context 'validation error' do
      let(:params) { { binary_choice_form: { check_client_details: nil } } }

      it 'displays an error if nothing selected' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Select if your client&#39;s details are correct or not')
      end
    end
  end
end
