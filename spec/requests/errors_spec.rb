require "rails_helper"

RSpec.describe ErrorsController, type: :request do
  describe "actions that result in error pages being shown" do
    describe "unknown page" do
      context "with default locale" do
        before { get "/unknown/path" }

        it "redirect to page not found" do
          expect(response).to redirect_to("/error/page_not_found?locale=en")
        end
      end

      context "with Welsh locale" do
        around(:each) do |example|
          I18n.with_locale(:cy) { example.run }
        end

        before { get "/unknown/path", params: { locale: "cy" } }

        it "redirect to page not found" do
          expect(response).to redirect_to("/error/page_not_found?locale=cy")
        end
      end
    end

    describe "object not found" do
      context "with default locale" do
        before { get feedback_path(SecureRandom.uuid) }

        it "redirect to page not found" do
          expect(response).to redirect_to("/error/page_not_found?locale=en")
        end
      end

      context "with Welsh locale" do
        around(:each) do |example|
          I18n.with_locale(:cy) { example.run }
        end

        before { get feedback_path(SecureRandom.uuid, locale: :cy) }

        it "redirect to page not found" do
          expect(response).to redirect_to("/error/page_not_found?locale=cy")
        end
      end
    end
  end

  describe "GET /error/page_not_found" do
    subject { get error_path(:page_not_found) }

    before { subject }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct header" do
      expect(response.body).to include("Page not found")
    end
  end

  describe "GET /error/assessment_already_completed" do
    subject { get error_path(:assessment_already_completed) }

    before { subject }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct header" do
      expect(unescaped_response_body).to match(I18n.t("errors.show.assessment_already_completed.page_title"))
    end
  end

  describe "GET /error/access_denied" do
    subject { get error_path(:access_denied) }

    before { subject }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct header" do
      expect(response.body).to match(/Access denied/)
    end
  end
end
