require 'rails_helper'

RSpec.describe 'Backable', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant }

  before { login_as application.provider }

  let(:page_1) { providers_legal_aid_application_address_lookup_path(application) }
  let(:page_2) { providers_legal_aid_application_address_path(application) }
  let(:page_3) { providers_legal_aid_application_proceedings_types_path(application) }

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

  describe 'back_path' do
    before do
      get page_1
      get page_2
      patch page_2, params: address_params
      get page_3
    end

    it 'has a back link to the previous page' do
      expect(response.body).to have_back_link("#{page_2}?back=true")
    end

    context 'we reload the current page several times' do
      before do
        get page_3
        get page_3
      end

      it 'has a back link to the previous page' do
        expect(response.body).to have_back_link("#{page_2}?back=true")
      end
    end

    context 'we go back once' do
      it 'redirects to same page without the param' do
        get "#{page_2}?back=true"
        expect(response).to redirect_to(page_2)
      end

      it 'has a link to the previous page' do
        get "#{page_2}?back=true"
        get page_2
        expect(response.body).to have_back_link("#{page_1}?back=true")
      end
    end
  end
end
