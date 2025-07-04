require "rails_helper"

RSpec.describe "Providers::ApplicationDependable" do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET an action" do
    let(:get_request) { get providers_legal_aid_application_applicant_details_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      it "sets provider_step to be the current controller name" do
        expect { get_request }.to change { legal_aid_application.reload.provider_step }.from(nil).to("applicant_details")
      end

      context "with a controller that is configured to skip the provider_step update" do
        let(:get_request) { get providers_legal_aid_application_task_list_path(legal_aid_application) }

        it "does not set provider_step" do
          expect { get_request }.not_to change { legal_aid_application.reload.provider_step }.from(nil)
        end
      end
    end
  end
end
