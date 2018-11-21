require 'rails_helper'

RSpec.describe 'address selections requests', type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }

  describe 'POST /providers/applications/:legal_aid_application_id/address_selections' do
    let(:address_list) do
      [
        { "address_line_one": '1', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '2', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '3', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '4', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '5', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '6', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '7', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '8', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '9', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '10', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' },
        { "address_line_one": '12', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' }
      ].map(&:to_json)
    end
    let(:postcode) { 'DA7 4NG' }
    let(:serialized_address) { { "address_line_one": '5', "address_line_two": 'LONSDALE ROAD', "city": 'BEXLEYHEATH', "postcode": 'DA7 4NG' }.to_json }
    let(:normalized_postcode) { 'DA74NG' }
    let(:params) do
      {
        address_selection: {
          list: address_list,
          postcode: postcode,
          address: serialized_address
        }
      }
    end
    let(:post_request) { post providers_legal_aid_application_address_selections_path(legal_aid_application), params: params }

    context 'when the applicant does not exist' do
      let(:legal_aid_application) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        post_request

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context 'when no address was selected from the list' do
      let(:serialized_address) { '' }

      it 'does not create a new address record' do
        expect { post_request }.not_to change { Address.count }
      end

      it 'renders the address selection page' do
        post_request

        expect(response).to be_successful
        expect(unescaped_response_body).to match('Please select an address from the list')
        expect(unescaped_response_body).to match('Select an address')
        expect(unescaped_response_body).to match('[1-9]{1}[0-9]? addresses found')
      end
    end

    it 'creates a new address record associated with the applicant' do
      expect { post_request }.to change { applicant.reload.addresses.count }.by(1)
    end

    it 'redirects to next submission step' do
      post_request

      expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(legal_aid_application))
    end
  end
end
