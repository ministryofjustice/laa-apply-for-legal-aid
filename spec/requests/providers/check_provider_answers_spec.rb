require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_provider_answers' do
    let(:get_request) { get "/providers/applications/#{application_id}/check_provider_answers" }

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects to the applications page with an error' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'returns success' do
      get_request

      expect(response).to be_successful
    end

    it 'displays the correct page' do
      get_request

      expect(unescaped_response_body).to include('Check your answers')
    end

    it 'displays the correct proceeding' do
      get_request

      expect(unescaped_response_body).to include(application.proceeding_types[0].meaning)
    end

    it 'displays the correct client details' do
      get_request

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

  describe 'POST /providers/applications/:legal_aid_application_id/check_provider_answers/reset' do
    let(:post_request) { post "/providers/applications/#{application_id}/check_provider_answers/reset" }

    before do
      application.check_your_answers!
    end

    it 'should redirect back' do
      post_request
      expect(response).to redirect_to(providers_legal_aid_application_address_path(application))
    end

    context "the applicant's address used s address lookup service" do
      let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address_lookup) }
      let(:application_id) { application.id }
      let(:address_lookup_used) { true }

      it 'should redirect to the address lookup page' do
        post_request
        expect(response).to redirect_to(providers_legal_aid_application_address_selection_path(application))
      end
    end

    context "the applicant's address used manual entry" do
      let(:address_lookup_used) { false }

      it 'should redirect to manual address pagelookup page' do
        post_request
        expect(response).to redirect_to(providers_legal_aid_application_address_path(application))
      end
    end

    it 'should change the stage back to "initialized' do
      post_request
      expect(application.reload.initiated?).to be_truthy
    end
  end
end
