require "rails_helper"

RSpec.describe Citizens::ConsentsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }

  before { sign_in_citizen_for_application(legal_aid_application) }

  describe "GET /citizens/consent" do
    before { get citizens_consent_path }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_content(
        "Do you agree to share 3 months of bank statements with the LAA via " \
        "TrueLayer?",
      )
    end
  end

  describe "PATCH /citizens/consent" do
    before do
      freeze_time
      patch citizens_consent_path, params:
    end

    context "when consent is granted" do
      let(:params) { { legal_aid_application: { open_banking_consent: "true" } } }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end

      it "records the decision on the legal aid application" do
        expect(legal_aid_application.reload).to be_open_banking_consent
        expect(legal_aid_application.open_banking_consent_choice_at)
          .to eq(Time.current)
      end

      it "updates application state" do
        expect(legal_aid_application.reload).to be_applicant_entering_means
      end
    end

    context "when consent is not granted" do
      let(:params) { { legal_aid_application: { open_banking_consent: "false" } } }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end

      it "records the decision on the legal aid application" do
        expect(legal_aid_application.reload).not_to be_open_banking_consent
        expect(legal_aid_application.open_banking_consent_choice_at)
          .to eq(Time.current)
      end

      it "updates application state" do
        expect(legal_aid_application.reload).to be_use_ccms
      end
    end

    context "with no values given" do
      let(:params) { { legal_aid_application: { open_banking_consent: nil } } }

      it "returns an error" do
        expect(page).to have_content(
          "Select yes if you agree to share your bank account information " \
          "with the LAA",
        )
      end
    end
  end
end
