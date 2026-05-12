require "rails_helper"

RSpec.describe "application confirmation requests" do
  let(:application) { create(:legal_aid_application, :with_applicant) }

  describe "GET /providers/applications/:legal_aid_application_id/application_confirmation" do
    subject(:get_request) { get providers_legal_aid_application_application_confirmation_path(application) }

    before do
      login_as application.provider
      get_request
    end

    it "returns success" do
      expect(response).to be_successful
    end

    it "displays application_ref" do
      expect(response.body).to include(application.application_ref)
    end
  end
end
