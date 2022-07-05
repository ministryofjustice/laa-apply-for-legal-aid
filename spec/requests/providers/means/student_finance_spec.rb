require "rails_helper"

RSpec.describe "student_finance", type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/student_finance" do
    before do
      login_as provider
      get providers_legal_aid_application_means_student_finance_path(legal_aid_application)
    end

    it "returns success" do
      expect(response).to be_successful
    end

    it "contains the correct content" do
      expect(response.body).to include("Does your client receive student finance?")
    end
  end
end
