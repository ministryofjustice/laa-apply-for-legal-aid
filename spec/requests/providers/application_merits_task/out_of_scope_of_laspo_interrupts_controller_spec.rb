require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::OutOfScopeOfLaspoInterruptsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/out_of_scope_of_laspo_interrupt" do
    subject(:get_request) { get providers_legal_aid_application_out_of_scope_of_laspo_interrupt_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success and the correct template" do
        expect(response).to have_http_status(:ok).and render_template("providers/application_merits_task/out_of_scope_of_laspo_interrupts/show")
      end
    end
  end
end
