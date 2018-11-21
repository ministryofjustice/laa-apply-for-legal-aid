require 'rails_helper'

RSpec.describe 'address requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:applicant) { legal_aid_application.applicant }
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

  describe 'GET /providers/applications/:legal_aid_application_id/address/new' do
    let(:get_request) { get new_providers_legal_aid_application_address_path(legal_aid_application) }

    context 'when the applicant does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'returns success' do
      get_request

      expect(response).to be_successful
      expect(unescaped_response_body).to include("Enter your client's address manually")
    end
  end

  describe 'POST /providers/applications/:legal_aid_application_id/address' do
    let(:post_request) { post providers_legal_aid_application_address_path(legal_aid_application), params: address_params }

    context 'when the legal aid application does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        post_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'displays an error if the applicant does not exist' do
        post_request
        expect(flash[:error]).to eq('Invalid application')
      end

      it 'does NOT create an address record' do
        expect { post_request }.not_to change { Address.count }
      end
    end

    context 'with a valid address' do
      it 'redirects successfully to the next step' do
        post_request
        expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(legal_aid_application))
      end

      it 'creates an address record' do
        expect { post_request }.to change { applicant.addresses.count }.by(1)
      end
    end

    context 'with an invalid address' do
      before { address_params[:address].delete(:postcode) }

      it 'renders the form again if validation fails' do
        post_request
        expect(unescaped_response_body).to include("Enter your client's address manually")
        expect(response.body).to include('Enter a postcode')
      end
    end
  end
end
