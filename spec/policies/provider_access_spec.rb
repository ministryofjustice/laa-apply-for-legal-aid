require 'rails_helper'

RSpec.describe 'Provider access', type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { create :provider }

  it 'allows provider to access page in flow until completion' do
    login_as legal_aid_application.provider

    # Access page initially
    get providers_legal_aid_application_address_lookup_path(legal_aid_application)
    expect(response).to have_http_status(:ok)

    # Application is completed
    legal_aid_application.update(state: :assessment_submitted)

    # On access to page after completion user is redirected to submitted application
    get providers_legal_aid_application_address_lookup_path(legal_aid_application)
    expect(response).to redirect_to(providers_legal_aid_application_submitted_application_path(legal_aid_application))
  end

  it 'prevents another provider accessing the page' do
    login_as provider

    get providers_legal_aid_application_address_lookup_path(legal_aid_application)

    expect(response).to redirect_to(error_path :access_denied)
  end
end
