require "rails_helper"

RSpec.describe Providers::InScopeOfLasposController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }

  before { login_as provider }

  describe "GET /providers/:application_id/in_scope_of_laspo" do
    subject { get providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application) }

    before { subject }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the page" do
      expect(unescaped_response_body).to include(I18n.t("providers.in_scope_of_laspos.show.page_title"))
    end
  end

  describe "PATCH /providers/:application_id/in_scope_of_laspo" do
    subject { patch providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application), params: }

    before do
      allow(Setting).to receive(:enable_mini_loop?).and_return(mini_loop?)
      subject
    end

    let(:mini_loop?) { false }

    context "choose yes" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: true } } }

      it "updates the record" do
        expect(legal_aid_application.reload.in_scope_of_laspo).to be(true)
      end

      it "redirects to the next page" do
        expect(response).to redirect_to(next_flow_step)
      end
    end

    context "choose no" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: false } } }

      it "updates the record" do
        expect(legal_aid_application.reload.in_scope_of_laspo).to be(false)
      end

      it "redirects to the next page" do
        expect(response).to redirect_to(next_flow_step)
      end

      context "when the mini_loop flag is on" do
        let(:mini_loop?) { true }

        it "redirects to the next page" do
          proceeding_id = legal_aid_application.proceedings.first.id
          expect(response).to redirect_to(providers_legal_aid_application_client_involvement_type_path(legal_aid_application.id, proceeding_id))
        end
      end
    end

    context "choose nothing" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: nil } } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.in_scope_of_laspo.blank"))
      end
    end

    context "Form submitted with Save as draft button" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: false }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
