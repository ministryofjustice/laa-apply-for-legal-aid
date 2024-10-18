require "rails_helper"

RSpec.describe Admin::FeedbackController do
  let(:count) { 2 }
  let(:admin_user) { create(:admin_user) }
  let(:params) { {} }

  before do
    create(:feedback, satisfaction: "satisfied")
    create_list(:feedback, count)
    sign_in admin_user
  end

  describe "GET /admin/feedback" do
    subject(:get_request) { get admin_feedback_path(params) }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays title" do
      get_request
      expect(response.body).to include(I18n.t("admin.feedback.show.heading_1"))
    end

    it "displays feedback" do
      get_request
      Feedback.find_each do |feedback|
        expect(response.body).to include(feedback.improvement_suggestion)
      end
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
        let(:count) { 4 }

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
