require "rails_helper"

# Requires mocking the config neccessary to display error pages as on production
# environments, or errors will be handled as for test/development environment
#  - i.e rendering the helpful rails error pages.
#
RSpec.describe ErrorsController, :show_exceptions do
  context "when page not found due to path not existing" do
    context "with no locale" do
      before { get("/unknown/path") }

      it "responds with not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found with default locale, English content" do
        expect(response).to render_template("errors/show/_page_not_found")
        expect(page).to have_css("h1", text: "Page not found")
      end
    end

    context "with Welsh locale", :use_welsh_locale do
      before { get("/unknown/path", params: { locale: :cy }) }

      it "responds with not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found with Welsh content" do
        expect(response).to render_template("errors/show/_page_not_found")
        expect(page).to have_css("h1", text: "dnuof ton egaP")
      end
    end

    # Real world scenario where an invalid locale is supplied and previusly resulted in a 500 error with no in-app page serveable
    context "with invalid locale" do
      before do
        allow(Rails.logger).to receive(:warn)
        get("/unknown/path", params: { locale: "enMobile" })
      end

      it "responds with not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found with default locale, English content" do
        expect(response).to render_template("errors/show/_page_not_found")
        expect(page).to have_css("h1", text: "Page not found")
      end

      it "logs the invalid locale request" do
        expect(Rails.logger).to have_received(:warn).with(/Invalid locale requested: "enMobile".*\. Falling back to default locale./)
      end
    end
  end

  context "when page not found due to non-html format" do
    let(:get_invalid_path) { get("/unknown/path.xml") }

    context "with default locale" do
      it "responds with expected http status" do
        get_invalid_path
        expect(response).to have_http_status(:not_found)
      end

      it "renders not found plain text" do
        get_invalid_path
        expect(response.body).to eq("Not found")
      end
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get("/unknown/path.xml", params: { locale: :cy })

        expect(response.body).to eq("Not found")
      end
    end
  end

  context "when page not found due to object not found" do
    let(:get_invalid_id) { get admin_firm_providers_path(SecureRandom.uuid) }
    let(:admin_user) { create(:admin_user) }

    before do
      sign_in admin_user
    end

    context "with default locale" do
      it "responds with expected http status" do
        get_invalid_id
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found" do
        get_invalid_id
        expect(response).to render_template("errors/show/_page_not_found")
      end
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get admin_firm_providers_path(SecureRandom.uuid, locale: :cy)
        expect(page)
          .to have_css("h1", text: "dnuof ton egaP")
      end
    end
  end

  context "when page not found due to legal_aid_application not found" do
    let(:get_invalid_id) { get providers_legal_aid_application_previous_references_path(legal_aid_application_id: SecureRandom.uuid) }
    let(:provider) { create(:provider) }

    before { sign_in provider }

    it "responds with expected http status" do
      get_invalid_id
      expect(response).to have_http_status(:not_found)
    end

    it "renders page not found" do
      get_invalid_id
      expect(response).to render_template("errors/show/_page_not_found")
    end
  end

  context "when internal server error/500 due to code fault" do
    let(:get_invalid_id) { get admin_firm_providers_path(SecureRandom.uuid) }
    let(:admin_user) { create(:admin_user) }

    before do
      sign_in admin_user
      allow(Firm).to receive(:find).and_raise { ArgumentError.new("dummy error to emulate 500 internal server error") }
    end

    context "with default locale" do
      it "responds with expected http status" do
        get_invalid_id
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders internal server error" do
        get_invalid_id
        expect(response).to render_template("errors/show/_internal_server_error")
      end
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get admin_firm_providers_path(SecureRandom.uuid, locale: :cy)
        expect(page)
          .to have_css("h1", text: "ecivres ruo htiw gnorw tnew gnihtemos ,yrroS")
      end
    end
  end

  context "when access denied/403 due to attempt to access another providers application" do
    let(:not_their_application) { create(:legal_aid_application, provider: create(:provider)) }
    let(:get_unauthorized) { get providers_legal_aid_application_previous_references_path(not_their_application) }

    before do
      sign_in create(:provider)
      get_unauthorized
      follow_redirect! # required because currently handled via a redirect
    end

    context "with default locale" do
      it "responds with expected http status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders access denied" do
        expect(response).to render_template("errors/show/_access_denied")
      end
    end
  end

  describe "GET /error/page_not_found" do
    subject(:get_error) { get error_path(:page_not_found) }

    it "responds with not_found/404 status" do
      get_error
      expect(response).to have_http_status(:not_found)
    end

    it "renders page not found" do
      get_error
      expect(response).to render_template("errors/show/_page_not_found")
    end

    it "displays the correct content" do
      get_error
      expect(page)
        .to have_css("h1", text: "Page not found")
        .and have_content("If you typed the web address, check it is correct.")
        .and have_content("If you pasted the web address, check you copied the entire address.")
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get error_path(:page_not_found, locale: :cy)
        expect(page)
          .to have_css("h1", text: "dnuof ton egaP")
      end
    end
  end

  describe "GET /error/assessment_already_completed" do
    subject(:get_error) { get error_path(:assessment_already_completed) }

    it "responds with ok/200 status" do
      get_error
      expect(response).to have_http_status(:ok)
    end

    it "renders assessment_already_completed" do
      get_error
      expect(response).to render_template("errors/show/_assessment_already_completed")
    end

    it "displays the correct header" do
      get_error
      expect(page).to have_css("h1", text: "You've already shared your financial information")
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get error_path(:assessment_already_completed, locale: :cy)
        expect(page)
          .to have_css("h1", text: "tnemssessa laicnanif ruoy detelpmoc ydaerla ev'uoY")
      end
    end
  end

  describe "GET /error/access_denied" do
    subject(:get_error) { get error_path(:access_denied) }

    it "responds with forbidden/403 status" do
      get_error
      expect(response).to have_http_status(:forbidden)
    end

    it "renders assessment_already_completed" do
      get_error
      expect(response).to render_template("errors/show/_access_denied")
    end

    it "displays the correct header" do
      get_error
      expect(page).to have_css("h1", text: "Access denied")
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get error_path(:access_denied, locale: :cy)
        expect(page)
          .to have_css("h1", text: "deined sseccA")
      end
    end
  end

  describe "GET /error/internal_server_error" do
    subject(:get_error) { get error_path(:internal_server_error) }

    it "responds with internal_server_error/500 status" do
      get_error
      expect(response).to have_http_status(:internal_server_error)
    end

    it "renders internal_server_error" do
      get_error
      expect(response).to render_template("errors/show/_internal_server_error")
    end

    it "displays the correct header" do
      get_error
      expect(page)
        .to have_css("h1", text: "Sorry, something went wrong with our service")
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get error_path(:internal_server_error, locale: :cy)
        expect(page)
          .to have_css("h1", text: "ecivres ruo htiw gnorw tnew gnihtemos ,yrroS")
      end
    end
  end

  describe "GET /error/benefit_checker_down" do
    subject(:get_error) { get error_path(:benefit_checker_down) }

    it "responds with internal_server_error/500 status" do
      get_error
      expect(response).to have_http_status(:internal_server_error)
    end

    it "renders benefit_checker_down" do
      get_error
      expect(response).to render_template("errors/show/_benefit_checker_down")
    end

    it "displays the correct header" do
      get_error
      expect(page)
        .to have_css("h1", text: "Sorry, there is a problem")
    end

    context "with Welsh locale", :use_welsh_locale do
      it "displays the correct content" do
        get error_path(:benefit_checker_down, locale: :cy)
        expect(page)
          .to have_css("h1", text: "melborp a si ereht ,yrroS")
      end
    end
  end
end
