require "rails_helper"

RSpec.describe Citizens::ContactProvidersController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }

  describe "GET /citizens/contact_provider" do
    before do
      sign_in_citizen_for_application(legal_aid_application)
      get citizens_contact_provider_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_content("Contact your solicitor")
    end
  end
end
