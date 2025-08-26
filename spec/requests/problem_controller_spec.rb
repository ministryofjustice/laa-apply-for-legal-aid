require "rails_helper"

RSpec.describe ProblemController do
  describe "GET /problem" do
    before { get problem_index_path }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct content" do
      expect(unescaped_response_body).to match(I18n.t("problem.index.title"))
      expect(unescaped_response_body).to match(I18n.t("problem.index.ccms_or_try_later_html", url: Rails.configuration.x.laa_landing_page_target_url))
      expect(unescaped_response_body).to match(I18n.t("problem.index.answers_saved"))
    end
  end
end
