require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::ChildSubjectsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001]) }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/child_subjects" do
    subject(:get_request) { get providers_legal_aid_application_child_subject_path(legal_aid_application) }

    before do
      login_provider
      get_request
    end

    it "renders show with ok status" do
      expect(response).to have_http_status(:ok).and render_template("providers/proceedings_sca/child_subjects/show")
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when authenticated as a different provider" do
      let(:login_provider) { login_as create(:provider) }

      it_behaves_like "an authenticated provider from a different firm"
    end
  end
end
