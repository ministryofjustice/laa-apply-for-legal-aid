require "rails_helper"

RSpec.describe Providers::CorrespondenceAddress::LookupsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/address_lookup" do
    subject(:get_request) { get providers_legal_aid_application_correspondence_address_lookup_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the postcode entry page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Find your client's correspondence address")
      end
    end
  end

  describe "PATCH/providers/applications/:legal_aid_application_id/address_lookup" do
    subject(:patch_request) { patch providers_legal_aid_application_correspondence_address_lookup_path(legal_aid_application), params: }

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
      before { patch_request }

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
          patch_request
        end

        it "re-renders the form with the validation errors" do
          patch_request
          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("Enter a postcode in the correct format")
        end
      end

      context "with a valid postcode" do
        let(:postcode) { "SW1H 9EA" }

        it "saves the postcode and the location" do
          patch_request
          expect(applicant.address.postcode).to eq(postcode.delete(" ").upcase)
          expect(applicant.address.location).to eq("correspondence")
          expect(applicant.address.country_code).to eq("GBR")
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "and a building number" do
          before { params[:address_lookup][:building_number_name] = "Prospect Cottage" }

          it "saves the building name/number value" do
            patch_request
            expect(applicant.address.building_number_name).to eq("Prospect Cottage")
          end
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
