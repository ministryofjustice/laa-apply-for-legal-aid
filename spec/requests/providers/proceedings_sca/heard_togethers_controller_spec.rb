require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::HeardTogethersController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, proceeding_count:) }
  let(:proceeding_count) { 2 }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/heard_togethers" do
    subject(:get_request) { get providers_legal_aid_application_heard_togethers_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_provider
        get_request
      end

      context "when there is a core proceeding" do
        let(:core_sca) { legal_aid_application.proceedings.first.meaning }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include(I18n.t("providers.proceedings_sca.heard_togethers.show.page_title.single", core_sca:))
        end
      end

      context "when there is more than one core proceeding" do
        let(:proceeding_count) { 3 }

        it "returns http success" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("providers.proceedings_sca.heard_togethers.show.page_title.multiple"))
        end
      end
    end
  end
end
