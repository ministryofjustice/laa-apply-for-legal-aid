require "rails_helper"

RSpec.describe "provider confirm office" do
  let(:firm) { create(:firm) }
  let!(:office) { create(:office, firm:) }
  let!(:office2) { create(:office, firm:) }
  let(:provider) { create(:provider, firm:, selected_office: office) }

  describe "GET providers/confirm_office" do
    subject(:get_request) { get providers_confirm_office_path }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider uses an invalid login" do
      let(:provider) { create(:provider, invalid_login_details: "role") }

      before do
        login_as provider
        get_request
      end

      it "redirects to the invalid login page" do
        expect(response).to redirect_to providers_invalid_login_path
      end
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct office legal aid code" do
        expect(unescaped_response_body).to include(office.code)
      end

      it "sets the page_history_id" do
        expect(session["page_history_id"]).not_to be_nil
      end

      context "when the firm has only one office" do
        let(:office) { nil }

        it "assigns office 2 to the provider" do
          expect(provider.reload.selected_office).to eq office2
        end

        it "redirects to the legal aid applications page" do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end

      context "when the provider has not selected an office" do
        let(:provider) { create(:provider, firm:, selected_office: nil) }

        it "redirects to the select office page" do
          expect(response).to redirect_to providers_select_office_path
        end
      end
    end
  end

  describe "PATCH providers/confirm_office" do
    subject(:patch_request) { patch providers_confirm_office_path, params: }

    let(:params) { { binary_choice_form: { confirm_office: "true" } } }

    context "when the provider is authenticated" do
      before do
        allow(ProviderContractDetailsWorker).to receive(:perform_async).and_return(true)
        login_as provider
        patch_request
      end

      it "redirects to the legal aid applications page" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end

      context "when the params are invalid - nothing specified" do
        let(:params) { {} }

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("providers.confirm_offices.show.error"))
        end
      end

      context "when no is selected" do
        let(:params) { { binary_choice_form: { confirm_office: "false" } } }

        it "redirects to the office select page" do
          expect(response).to redirect_to providers_select_office_path
        end

        it "clears the existing office" do
          expect(provider.reload.selected_office).to be_nil
        end
      end
    end
  end
end
