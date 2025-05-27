require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::InScopeOfLasposController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant_and_child_section_8, legal_aid_application:) }

  before { login_as provider }

  describe "GET /providers/:application_id/in_scope_of_laspo" do
    subject(:get_laspo) { get providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application) }

    before { get_laspo }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the page" do
      expect(unescaped_response_body).to include(I18n.t("providers.application_merits_task.in_scope_of_laspos.show.page_title"))
    end
  end

  describe "PATCH /providers/:application_id/in_scope_of_laspo" do
    subject(:post_laspo) { patch providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application), params: }

    before do
      allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
      post_laspo
    end

    context "when the user chooses yes" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: true } } }

      it "updates the record" do
        expect(legal_aid_application.reload.in_scope_of_laspo).to be(true)
      end

      it "redirects to the next page" do
        expect(response).to redirect_to(next_flow_step)
      end
    end

    context "when the user chooses no" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: false } } }

      it "updates the record" do
        expect(legal_aid_application.reload.in_scope_of_laspo).to be(false)
      end

      it "redirects to the next page" do
        expect(response).to redirect_to(next_flow_step)
      end
    end

    context "when the user chooses nothing" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: nil } } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.in_scope_of_laspo.blank"))
      end
    end

    context "when the form submitted with Save as draft button" do
      let(:params) { { legal_aid_application: { in_scope_of_laspo: false }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
      end
    end
  end
end
