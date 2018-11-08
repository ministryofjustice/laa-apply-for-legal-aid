require 'rails_helper'

RSpec.describe 'address requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:applicant) { application.applicant }
  let(:applicant_id) { applicant.id }
  let(:address_params) do
    {
      address:
      {
        address_line_one: '123',
        address_line_two: 'High Street',
        city: 'London',
        county: 'Greater London',
        postcode: 'SW1H 9AJ'
      }
    }
  end

  describe 'GET /providers/applicants/:applicant_id/addresses/new' do
    let(:get_request) { get "/providers/applicants/#{applicant_id}/addresses/new" }

    context 'when the applicant does not exist' do
      let(:applicant_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'returns success' do
      get_request

      expect(response).to be_successful
      expect(response.body).to include(CGI.escapeHTML("Enter your client's address manually"))
    end
  end

  describe 'POST /providers/applicants/:applicant_id/addresses' do
    let(:post_request) { post "/providers/applicants/#{applicant_id}/addresses", params: address_params }

    context 'when the applicant does not exist' do
      let(:applicant_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        post_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'does NOT create an address record' do
        expect { post_request }.not_to change { applicant.addresses.count }
      end
    end

    context 'with a valid address' do
      it 'redirects successfully to the next step' do
        post_request
        expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
      end

      it 'creates an address record' do
        expect { post_request }.to change { applicant.addresses.count }.by(1)
      end
    end

    context 'with an invalid address' do
      before { address_params[:address].delete(:postcode) }

      it 'renders the form again if validation fails' do
        post_request
        expect(response.body).to include(CGI.escapeHTML("Enter your client's address manually"))
        expect(response.body).to include('Enter a postcode')
      end
    end

    context 'with an invalid applicant' do
      let(:applicant_id) { SecureRandom.uuid }

      it 'displays an error if the applicant does not exist' do
        post_request
        expect(flash[:error]).to eq('Invalid applicant')
      end

      it 'redirects if the applicant does not exist' do
        post_request
        expect(response.body).to redirect_to(providers_legal_aid_applications_path)
      end
    end
  end
end
