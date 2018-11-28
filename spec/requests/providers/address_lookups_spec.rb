require 'rails_helper'

RSpec.describe 'address lookup requests', type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }

  describe 'GET /providers/applications/:legal_aid_application_id/address_lookup' do
    subject { get providers_legal_aid_application_address_lookup_path(legal_aid_application) }

    context 'when the applicant does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'shows the postcode entry page' do
      subject
      expect(response).to be_successful
      expect(unescaped_response_body).to include(I18n.t('forms.address_lookup.heading'))
    end
  end

  describe 'PATCH/providers/applications/:legal_aid_application_id/address_lookup' do
    let(:postcode) { 'DA7 4NG' }
    let(:normalized_postcode) { 'DA74NG' }
    let(:params) do
      {
        address_lookup: {
          postcode: postcode
        }
      }
    end
    subject { patch providers_legal_aid_application_address_lookup_path(legal_aid_application), params: params }

    context 'when the applicantion does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        subject

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context 'with an invalid postcode' do
      let(:postcode) { 'invalid-postcode' }

      it 'does NOT perform an address lookup with the provided postcode' do
        expect(AddressLookupService).not_to receive(:call)

        subject
      end

      it 're-renders the form with the validation errors' do
        subject

        expect(unescaped_response_body).to include('There is a problem')
        expect(unescaped_response_body).to include('Enter a postcode in the right format')
      end
    end

    context 'with a valid postcode' do
      let(:postcode) { 'DA7 4NG' }

      it 'saves the postcode' do
        subject

        expect(applicant.address.postcode).to eq(postcode.delete(' ').upcase)
      end

      it 'redirects to the address selection page' do
        subject

        expect(response).to redirect_to(providers_legal_aid_application_address_selection_path)
      end
    end
  end
end
