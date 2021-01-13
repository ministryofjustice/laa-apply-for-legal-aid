require 'rails_helper'

RSpec.describe 'Backable', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant }

  before { login_as application.provider }

  let(:page1) { providers_legal_aid_application_address_lookup_path(application) }
  let(:page2) { providers_legal_aid_application_address_path(application) }
  let(:page3) { providers_legal_aid_application_proceedings_types_path(application) }

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
      get page1
      get page2
      patch page2, params: address_params
      get page3
    end

    it 'has a back link to the previous page' do
      expect(response.body).to have_back_link("#{page2}&back=true")
    end

    context 'we reload the current page several times' do
      before do
        get page3
        get page3
      end

      it 'has a back link to the previous page' do
        expect(response.body).to have_back_link("#{page2}&back=true")
      end
    end

    context 'we go back once' do
      it 'redirects to same page without the param' do
        get "#{page2}&back=true"
        expect(response).to redirect_to(page2)
      end

      it 'has a link to the previous page' do
        get "#{page2}&back=true"
        get page2
        expect(response.body).to have_back_link("#{page1}&back=true")
      end
    end
  end
end
