require "rails_helper"

RSpec.describe Citizens::LegalAidApplicationsController do
  let(:legal_aid_application) do
    create(
      :application,
      :with_applicant,
      :with_non_passported_state_machine,
      :awaiting_applicant,
      completed_at:,
      applicant: build(:applicant, first_name: "Test", last_name: "Applicant"),
      provider: build(:provider, firm: build(:firm, name: "Test Firm")),
    )
  end

  let(:citizen_access_token) do
    create(
      :citizen_access_token,
      legal_aid_application:,
    )
  end

  let(:completed_at) { nil }
  let(:token) { citizen_access_token.token }

  describe "GET citizens/applications/:id" do
    subject(:request) do
      get citizens_legal_aid_application_path(token)
    end

    it "redirects to applications" do
      request
      expect(response).to redirect_to(citizens_legal_aid_applications_path)
    end

    it "sets the page_history_id" do
      request
      expect(session["page_history_id"]).not_to be_nil
    end

    context "when the applicant has reached the check your answers page" do
      let(:legal_aid_application) do
        create(
          :application,
          :with_applicant,
          :with_non_passported_state_machine,
          :checking_citizen_answers,
          completed_at:,
          applicant: build(:applicant, first_name: "Test", last_name: "Applicant"),
          provider: build(:provider, firm: build(:firm, name: "Test Firm")),
        )
      end

      it "redirects back there" do
        request
        expect(response).to redirect_to(citizens_check_answers_path)
      end
    end

    context "when no matching legal aid application exists", :show_exceptions do
      let(:token) { SecureRandom.uuid }

      it "renders page not found" do
        request
        expect(response).to have_http_status(:not_found)
        expect(response).to render_template("errors/show/_page_not_found")
      end
    end

    context "when applicant has completed the means assessment" do
      let(:completed_at) { 1.day.ago }

      it "redirects to error page (assessment already completed)" do
        request
        expect(response).to redirect_to(error_path(:assessment_already_completed))
      end
    end

    context "when the link has expired" do
      before { travel_to citizen_access_token.expires_on }

      it "redirects to error page (link expired)" do
        request
        expect(response).to redirect_to(citizens_resend_link_request_path(token))
      end
    end
  end

  describe "GET citizens/applications" do
    subject(:request) do
      get citizens_legal_aid_application_path(citizen_access_token.token)
      get citizens_legal_aid_applications_path
    end

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end

    it "sets the application_id session variable" do
      request
      expect(session[:current_application_id]).to eq(legal_aid_application.id)
    end

    it "returns the correct application", :aggregate_failures do
      request
      expect(page).to have_content("Test Applicant")
      expect(page).to have_content("Test Firm")
    end

    context "when a provider is logged in" do
      let(:provider) { create(:provider, username: "different-provider") }

      before { sign_in provider }

      it "logs out the provider" do
        request
        expect(page).to have_no_content("different-provider")
      end
    end

    context "when applicant has completed the means assessment" do
      subject(:request) do
        get citizens_legal_aid_application_path(citizen_access_token.token)
        legal_aid_application.update!(completed_at: 1.day.ago)
        get citizens_legal_aid_applications_path
      end

      it "redirects to error page (assessment already completed)" do
        request
        expect(response).to redirect_to(error_path(:assessment_already_completed))
      end
    end
  end
end
