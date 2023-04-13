require "rails_helper"

RSpec.describe Providers::Partners::AddressLookupsController do
  let(:partner) { create(:partner) }
  let(:legal_aid_application) { partner.legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partner_address_lookup" do
    subject(:get_address_lookup) { get providers_legal_aid_application_partners_address_lookup_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_address_lookup }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_address_lookup
      end

      it "shows the postcode entry page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Enter the partner's correspondence address")
      end
    end
  end

  describe "PATCH/providers/applications/:legal_aid_application_id/partner_address_lookup" do
    subject(:patch_lookup) { patch providers_legal_aid_application_partners_address_lookup_path(legal_aid_application), params: }

    let(:postcode) { "SW1H 9EA" }
    let(:normalized_postcode) { "SW1H9AE" }
    let(:submit_button) { {} }
    let(:params) do
      {
        address_lookup: {
          postcode:,
        },
      }.merge(submit_button)
    end

    context "when the provider is not authenticated" do
      before { patch_lookup }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "with an invalid postcode" do
        let(:postcode) { "invalid-postcode" }

        it "does NOT perform an address lookup with the provided postcode" do
          expect(AddressLookupService).not_to receive(:call)
          patch_lookup
        end

        it "re-renders the form with the validation errors" do
          patch_lookup
          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("Enter a real postcode")
        end
      end

      context "with a valid postcode" do
        let(:postcode) { "SW1H 9EA" }

        it "saves the postcode" do
          patch_lookup
          expect(partner.reload.postcode).to eq(postcode.delete(" ").upcase)
        end

        it "redirects to the address selection page" do
          patch_lookup
          expect(response).to redirect_to(providers_legal_aid_application_partners_address_selection_path)
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_lookup
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_lookup }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
