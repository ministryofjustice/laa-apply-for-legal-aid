require 'rails_helper'

RSpec.describe 'address lookup requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { application.applicant }
  let(:applicant_id) { applicant.id }

  describe 'GET /providers/applicants/:applicant_id/address_lookups/new' do
    let(:get_request) { get "/providers/applicants/#{applicant_id}/address_lookups/new" }

    context 'when the applicant does not exist' do
      let(:applicant_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        get_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'shows the postcode entry page' do
      get_request

      expect(response).to be_successful
      expect(response.body).to include(I18n.t('forms.address_lookup.heading'))
    end
  end

  describe 'POST /providers/applicants/:applicant_id/address_lookups/' do
    let(:postcode) { 'DA7 4NG' }
    let(:normalized_postcode) { 'DA74NG' }
    let(:params) do
      {
        address_lookup: {
          postcode: postcode
        }
      }
    end
    let(:post_request) { post "/providers/applicants/#{applicant_id}/address_lookups", params: params }

    context 'when the applicant does not exist' do
      let(:applicant_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        post_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context 'with a valid postcode', :vcr do
      let(:postcode) { 'DA7 4NG' }

      it 'performs an address lookup with the provided postcode' do
        expect(AddressLookupService)
          .to receive(:call).with(normalized_postcode).and_call_original

        post_request
      end

      it 'renders the address selection page' do
        post_request

        expect(response).to be_successful
        expect(unescaped_response_body).to match('Select an address')
        expect(unescaped_response_body).to match('[1-9]{1}[0-9]? addresses found')
      end

      context 'but the lookup does not return any valid results' do
        let(:postcode) { 'SW1H 9AJ' } # NOTE: test account does not return any results for this postcode
        let(:form_heading) { "Enter your client's address manually" }
        let(:error_message) { "Sorry - we couldn't find any addresses for that postcode, please enter the address manually" }

        it 'renders the manual address selection page' do
          post_request

          expect(response).to be_successful
          expect(unescaped_response_body).to match(form_heading)
          expect(unescaped_response_body).to match(error_message)
        end
      end
    end
  end
end
