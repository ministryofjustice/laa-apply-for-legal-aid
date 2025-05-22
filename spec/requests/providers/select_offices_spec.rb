require "rails_helper"

RSpec.describe "provider selects office" do
  let(:firm) { create(:firm) }
  let!(:first_office) { create(:office, firm:) }
  let!(:second_office) { create(:office, firm:) }
  let!(:third_office) { create(:office, firm:) }

  let(:provider) { create(:provider, firm:, offices: [first_office, second_office]) }

  describe "GET providers/select_office" do
    subject(:get_request) { get providers_select_office_path }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the offices of the provider" do
        expect(unescaped_response_body).to include(first_office.code)
        expect(unescaped_response_body).to include(second_office.code)
      end

      it "does not display offices belonging to the firm but not the provider" do
        expect(unescaped_response_body).not_to include(third_office.code)
      end
    end
  end

  describe "PATCH providers/select_office" do
    subject(:patch_request) { patch providers_select_office_path, params: }

    let(:params) do
      {
        provider: { selected_office_id: second_office.id },
      }
    end

    context "when the provider is authenticated" do
      before do
        allow(ProviderContractDetailsWorker).to receive(:perform_async).and_return(true)
        login_as provider
        patch_request
      end

      it "updates the record" do
        expect(provider.reload.selected_office.id).to eq second_office.id
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
          expect(response.body).to include(I18n.t("activemodel.errors.models.provider.attributes.selected_office_id.blank"))
        end
      end

      context "when the params are invalid - nothing specified - selects office from different provider" do
        let(:params) do
          {
            provider: { selected_office_id: third_office.id },
          }
        end

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("activemodel.errors.models.provider.attributes.selected_office_id.blank"))
        end
      end
    end
  end
end
