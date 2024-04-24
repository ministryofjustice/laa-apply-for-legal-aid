require "rails_helper"

RSpec.describe Providers::CorrespondenceAddress::ManualsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }
  let(:address) { applicant.address }
  let(:address_params) do
    {
      address:
      {
        address_line_one: "123",
        address_line_two: "High Street",
        city: "London",
        county: "Greater London",
        postcode: "SW1H 9AJ",
      },
    }
  end

  describe "GET /providers/applications/:legal_aid_application_id/address/edit" do
    subject(:get_request) { get providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns success" do
        get_request
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Enter your client's correspondence address")
      end

      context "when the applicant already entered an address" do
        let!(:address) { create(:address, applicant:) }

        it "fills the form with the existing address" do
          get_request
          expect(unescaped_response_body).to include(address.address_line_one)
          expect(unescaped_response_body).to include(address.address_line_two)
          expect(unescaped_response_body).to include(address.city)
          expect(unescaped_response_body).to include(address.county)
          expect(unescaped_response_body).to include(address.postcode)
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/address" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application),
        params: address_params.merge(submit_button),
      )
    end

    let(:submit_button) { {} }

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "with a valid address" do
        it "creates an address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
          expect(address.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(address.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(address.city).to eq(address_params[:address][:city])
          expect(address.county).to eq(address_params[:address][:county])
          expect(address.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
          expect(address.country_code).to eq("GBR")
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with an invalid address" do
        before { address_params[:address].delete(:postcode) }

        it "renders the form again if validation fails" do
          patch_request
          expect(unescaped_response_body).to include("Enter your client's correspondence address")
          expect(response.body).to include("Enter a postcode")
        end
      end

      context "with an already existing address" do
        before { create(:address, applicant:) }

        it "does not create a new address record" do
          expect { patch_request }.not_to change { applicant.addresses.count }
        end

        it "updates the current address" do
          patch_request
          expect(address.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(address.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(address.city).to eq(address_params[:address][:city])
          expect(address.county).to eq(address_params[:address][:county])
          expect(address.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
        end
      end

      context "when a previous address lookup failed" do
        let(:address_params) do
          {
            address:
            {
              lookup_postcode: "SW1H 9AJ",
              address_line_one: "123",
              address_line_two: "High Street",
              city: "London",
              county: "Greater London",
              postcode: "SW1H 9AJ",
            },
          }
        end

        it "records that address lookup was used" do
          patch_request
          expect(address.lookup_used).to be(true)
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
