require 'rails_helper'

RSpec.describe Providers::SubmittedApplicationsController, type: :request do
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_everything,
           :with_proceeding_types,
           :with_chances_of_success,
           :assessment_submitted,
           provider: provider
  end

  let(:login) { login_as legal_aid_application.provider }
  let(:html) { Nokogiri::HTML(response.body) }
  let(:print_buttons) { html.xpath('//button[contains(text(), "Print application")]') }

  before do
    login
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/submitted_application' do
    subject do
      get providers_legal_aid_application_submitted_application_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays reference' do
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    it 'shows client declaration only when printing the page' do
      expect(html.at_css('#client-declaration').classes).to include('only-print')
    end

    it 'hidess print buttons when printing the page' do
      print_buttons.each do |print_button|
        expect(print_button.ancestors.at_css('.no-print')).to_not eq(nil)
      end
    end

    it 'includes the name of the firm' do
      subject
      expect(unescaped_response_body).to include(firm.name)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end

    context 'with another provider' do
      let(:login) { login_as create(:provider) }

      it 'redirects to access denied error' do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end
end
