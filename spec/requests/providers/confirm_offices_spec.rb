require "rails_helper"

RSpec.describe "provider confirm office" do
  let(:office1) { create(:office, code: "1X11111", firm: provider.firm) }
  let(:office2) { create(:office, code: "2X22222", firm: provider.firm) }

  describe "GET providers/confirm_office" do
    subject(:get_request) { get providers_confirm_office_path }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the firm has 2 offices and one is previously selected" do
        let(:provider) { create(:provider, firm: create(:firm), with_office_selected: false) }

        before do
          office1
          office2

          provider.update!(selected_office: office1)
        end

        it "returns http success" do
          get_request

          expect(response).to have_http_status(:ok)
        end

        it "displays the correct office legal aid code" do
          get_request

          expect(page).to have_content("Is 1X11111 your office account number?")
        end

        it "sets the page_history_id" do
          get_request

          expect(session["page_history_id"]).not_to be_nil
        end
      end

      context "when the firm has only one office and no office selected" do
        let(:provider) { create(:provider, firm: create(:firm), with_office_selected: false) }

        before do
          create(:office, code: "3X33333", firm: provider.firm)
        end

        it "sets the page_history_id", skip: "TODO: AP-6201 - flow will need changing if we reimplement feature" do
          get_request

          expect(session["page_history_id"]).not_to be_nil
        end

        it "selects that office for the provider automatically", skip: "TODO: AP-6201 - flow will need changing if we reimplement feature" do
          get_request

          expect(provider.reload.selected_office.code).to eq "3X33333"
        end

        it "returns http redirect" do
          get_request

          expect(response).to have_http_status(:redirect)
        end

        it "redirects to the legal aid applications page", skip: "TODO: AP-6201 - flow will need changing if we reimplement feature" do
          get_request

          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end

      context "when the provider has not selected an office" do
        let(:provider) { create(:provider, firm: create(:firm), with_office_selected: false) }

        it "redirects to the select office page" do
          get_request

          expect(response).to redirect_to providers_select_office_path
        end
      end
    end
  end

  describe "PATCH providers/confirm_office" do
    subject(:patch_request) { patch providers_confirm_office_path, params: }

    let(:provider) { create(:provider, firm: create(:firm)) }

    let(:params) { { binary_choice_form: { confirm_office: "true" } } }

    context "when the provider is authenticated" do
      before do
        allow(ProviderContractDetailsWorker).to receive(:perform_async).and_return(true)
        login_as provider
        patch_request
      end

      it "redirects to the legal aid applications page" do
        expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
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
