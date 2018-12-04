require 'rails_helper'

RSpec.describe 'address requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:applicant) { legal_aid_application.applicant }
  let(:address) { applicant.address }
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

  describe 'GET /providers/applications/:legal_aid_application_id/address/edit' do
    let(:get_request) { get providers_legal_aid_application_address_path(legal_aid_application) }

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

    context 'when the applicant already entered an address' do
      let!(:address) { create :address, applicant: applicant }

      it 'fills the form with the existing address' do
        get_request

        expect(unescaped_response_body).to include(address.address_line_one)
        expect(unescaped_response_body).to include(address.address_line_two)
        expect(unescaped_response_body).to include(address.city)
        expect(unescaped_response_body).to include(address.county)
        expect(unescaped_response_body).to include(address.postcode)
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/address' do
    let(:patch_request) { patch providers_legal_aid_application_address_path(legal_aid_application), params: address_params }

    context 'when the legal aid application does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        patch_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'displays an error if the applicant does not exist' do
        patch_request
        expect(flash[:error]).to eq('Invalid application')
      end

      it 'does NOT create an address record' do
        expect { patch_request }.not_to change { Address.count }
      end
    end

    context 'with a valid address' do
      it 'redirects successfully to the next step' do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
      end

      it 'creates an address record' do
        expect { patch_request }.to change { applicant.addresses.count }.by(1)
        expect(address.address_line_one).to eq(address_params[:address][:address_line_one])
        expect(address.address_line_two).to eq(address_params[:address][:address_line_two])
        expect(address.city).to eq(address_params[:address][:city])
        expect(address.county).to eq(address_params[:address][:county])
        expect(address.postcode).to eq(address_params[:address][:postcode].delete(' ').upcase)
      end
    end

    context 'with an invalid address' do
      before { address_params[:address].delete(:postcode) }

      it 'renders the form again if validation fails' do
        patch_request
        expect(unescaped_response_body).to include("Enter your client's address manually")
        expect(response.body).to include('Enter a postcode')
      end
    end

    context 'with an already existing address' do
      before { create :address, applicant: applicant }

      it 'does not create a new address record' do
        expect { patch_request }.to_not change { applicant.addresses.count }
      end

      it 'updates the current address' do
        patch_request
        expect(address.address_line_one).to eq(address_params[:address][:address_line_one])
        expect(address.address_line_two).to eq(address_params[:address][:address_line_two])
        expect(address.city).to eq(address_params[:address][:city])
        expect(address.county).to eq(address_params[:address][:county])
        expect(address.postcode).to eq(address_params[:address][:postcode].delete(' ').upcase)
      end
    end

    context 'a previous address lookup failed' do
      let(:address_params) do
        {
          address:
          {
            lookup_postcode: 'SW1H 9AJ',
            address_line_one: '123',
            address_line_two: 'High Street',
            city: 'London',
            county: 'Greater London',
            postcode: 'SW1H 9AJ'
          }
        }
      end

      it 'records that address lookup was used' do
        patch_request

        expect(address.lookup_used).to eq(true)
      end
    end
  end
end
