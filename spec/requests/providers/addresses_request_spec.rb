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
    let(:perform_request) { get edit_providers_legal_aid_application_address_path(legal_aid_application) }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      context 'when the applicant does not exist' do
        let(:legal_aid_application) { SecureRandom.uuid }

        it 'redirects the user to the applications page with an error message' do
          perform_request

          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end

      it 'returns success' do
        perform_request

        expect(response).to be_successful
        expect(unescaped_response_body).to include("Enter your client's address manually")
      end

      context 'when the applicant already entered an address' do
        let!(:address) { create :address, applicant: applicant }

        it 'fills the form with the existing address' do
          perform_request

          expect(unescaped_response_body).to include(address.address_line_one)
          expect(unescaped_response_body).to include(address.address_line_two)
          expect(unescaped_response_body).to include(address.city)
          expect(unescaped_response_body).to include(address.county)
          expect(unescaped_response_body).to include(address.postcode)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/address' do
    let(:perform_request) { patch providers_legal_aid_application_address_path(legal_aid_application), params: address_params }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      context 'when the legal aid application does not exist' do
        let(:legal_aid_application) { SecureRandom.uuid }

        it 'redirects the user to the applications page with an error message' do
          perform_request

          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'displays an error if the applicant does not exist' do
          perform_request
          expect(flash[:error]).to eq('Invalid application')
        end

        it 'does NOT create an address record' do
          expect { perform_request }.not_to change { Address.count }
        end
      end

      context 'with a valid address' do
        it 'redirects successfully to the next step' do
          perform_request
          expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(legal_aid_application))
        end

        it 'creates an address record' do
          expect { perform_request }.to change { applicant.addresses.count }.by(1)
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
          perform_request
          expect(unescaped_response_body).to include("Enter your client's address manually")
          expect(response.body).to include('Enter a postcode')
        end
      end

      context 'with an already existing address' do
        before { create :address, applicant: applicant }

        it 'does not create a new address record' do
          expect { perform_request }.to_not change { applicant.addresses.count }
        end

        it 'updates the current address' do
          perform_request
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
          perform_request

          expect(address.lookup_used).to eq(true)
        end
      end
    end
  end
end
