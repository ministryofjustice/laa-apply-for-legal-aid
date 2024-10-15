require "rails_helper"

RSpec.describe Admin::SubmittedApplicationsReportsController do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list(:legal_aid_application, count, :with_applicant, :with_ccms_submission, :submitted_to_ccms) }
  let!(:unsubmitted_application) { create(:legal_aid_application, :with_applicant) }
  let(:admin_user) { create(:admin_user) }
  let(:params) { {} }

  before do
    sign_in admin_user
  end

  describe "GET /admin/submitted_applications_report" do
    subject(:get_request) { get admin_submitted_applications_report_path(params) }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays title" do
      get_request
      expect(response.body).to include(I18n.t("admin.submitted_applications_reports.show.heading_1"))
    end

    it "displays applications submitted to ccms" do
      get_request
      legal_aid_applications.each do |application|
        expect(response.body).to include(application.application_ref)
      end
    end

    it "does not display unsubmitted applications" do
      get_request
      expect(response.body).not_to include(unsubmitted_application.application_ref)
    end

    context "with pagination" do
      it "shows current total information" do
        get_request
        expect(page).to have_css(".app-pagination__info", text: "Showing 3 of 3")
      end

      it "does not show navigation links" do
        get_request
        expect(page).to have_no_css(".govuk-pagination")
      end

      context "and more applications than page size" do
        let(:params) { { page_size: 3 } }
        let(:count) { 5 }

        it "show page information" do
          get_request
          expect(page).to have_css(".app-pagination__info", text: "Showing 1 to 3 of 5 results")
        end

        it "shows pagination" do
          get_request
          expect(page).to have_css(".govuk-pagination", text: "12\nNext page")
        end
      end
    end

    context "when not authenticated" do
      before { sign_out admin_user }

      it "redirects to log in" do
        get_request
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
