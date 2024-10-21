require "rails_helper"

RSpec.describe Providers::HasEvidenceOfBenefitsController do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_dwp_override,
           :checking_applicant_details,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: %i[da004],
           df_options: { DA004: [Time.zone.now, Time.zone.now] })
  end

  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/:application_id/has_evidence_of_benefit" do
    before { get providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application) }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when evidence has been uploaded" do
      it "does not mention the caseworker in the main hint" do
        expect(response.body).to include I18n.t("providers.has_evidence_of_benefits.show.evidence_hint")
      end

      it "shows hint about uploading later in the hint for the Yes radio" do
        expect(response.body.gsub("&#39;", %('))).to include I18n.t("providers.has_evidence_of_benefits.show.radio_hint_yes")
      end
    end

    context "when the provider has said their client does not receive a joint benefit with their partner" do
      let(:benefit_text) { I18n.t(".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{legal_aid_application.dwp_override.passporting_benefit}") }

      it "displays the correct page" do
        expect(unescaped_response_body).to include(I18n.t("providers.has_evidence_of_benefits.show.h1_no_partner", passporting_benefit: benefit_text))
      end
    end

    context "when the provider has previously selected that the client gets a joint benefit with their partner" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_partner_and_joint_benefit, :with_dwp_override) }
      let(:benefit_text) { I18n.t(".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{legal_aid_application.dwp_override.passporting_benefit}") }
      let(:application_id) { legal_aid_application.id }

      it "displays the correct page" do
        expect(unescaped_response_body).to include(I18n.t("providers.has_evidence_of_benefits.show.h1_partner", passporting_benefit: benefit_text))
      end
    end
  end

  describe "PATCH /providers/:application_id/has_evidence_of_benefit" do
    before { patch providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application), params: }

    let(:has_evidence_of_benefit) { "true" }
    let(:params) do
      {
        dwp_override: {
          has_evidence_of_benefit:,
        },
      }
    end

    it "updates the state" do
      expect(legal_aid_application.reload.state).to eq "applicant_details_checked"
    end

    context "when the application state is already applicant_details_checked" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_dwp_override, :applicant_details_checked) }

      it "does not update the state" do
        expect(legal_aid_application).not_to receive(:applicant_details_checked!)
      end
    end

    it "updates the dwp_override model" do
      dwp_override = legal_aid_application.reload.dwp_override
      expect(dwp_override.has_evidence_of_benefit).to be true
    end

    it "redirects to the next page" do
      expect(response).to have_http_status(:redirect)
    end

    context "when the provider has not used delegated functions" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_dwp_override, :applicant_details_checked) }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    it "updates the state machine type" do
      expect(legal_aid_application.reload.state_machine).to be_a PassportedStateMachine
    end

    context "when the provider chose no" do
      let(:has_evidence_of_benefit) { "false" }

      it "updates the dwp_override model" do
        dwp_override = legal_aid_application.reload.dwp_override
        expect(dwp_override.has_evidence_of_benefit).to be false
      end

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end

      it "updates the state machine type" do
        expect(legal_aid_application.reload.state_machine).to be_a NonPassportedStateMachine
      end
    end

    context "when the provider has chosen nothing" do
      let(:has_evidence_of_benefit) { nil }

      it "show errors" do
        dwp_override = legal_aid_application.reload.dwp_override
        passporting_benefit = dwp_override.passporting_benefit.titleize
        error = I18n.t("activemodel.errors.models.dwp_override.attributes.has_evidence_of_benefit.blank", passporting_benefit:)
        expect(response.body).to include(error)
      end

      it "updates the state machine type" do
        expect(legal_aid_application.reload.state_machine).to be_a NonPassportedStateMachine
      end
    end

    context "when the form is submitted with the Save as draft button" do
      let(:params) { { draft_button: "Save as draft" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to submitted_providers_legal_aid_applications_path
      end
    end
  end
end
