require "rails_helper"

RSpec.describe Citizens::MeansTestResultsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :awaiting_applicant) }

  before do
    sign_in_citizen_for_application(legal_aid_application)
    complete_application
    request
  end

  describe "GET /citizens/means_test_result" do
    subject(:request) { get citizens_means_test_result_path }

    context "when the application has not been completed" do
      let(:complete_application) { nil }

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "with completed application" do
      let(:complete_application) do
        legal_aid_application.update!(completed_at: 1.minute.ago)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
