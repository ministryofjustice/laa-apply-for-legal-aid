require "rails_helper"

RSpec.describe Providers::HomeAddress::ManualsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }
  let(:home_address) { applicant.home_address }
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

  describe "GET /providers/applications/:legal_aid_application_id/home_address/enter_home_address" do
    subject(:get_request) { get providers_legal_aid_application_home_address_manual_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include("Enter your client's home address")
      end

      context "when the applicant already entered a UK home address" do
        let!(:home_address) { create(:address, applicant:, location: "home", country_code: "GBR", country_name: "United Kingdom") }

        it "fills the form with the existing address" do
          get_request
          expect(unescaped_response_body).to include(home_address.address_line_one)
          expect(unescaped_response_body).to include(home_address.address_line_two)
          expect(unescaped_response_body).to include(home_address.city)
          expect(unescaped_response_body).to include(home_address.county)
          expect(unescaped_response_body).to include(home_address.postcode)
        end
      end

      context "when the applicant already entered a non-UK home address" do
        let!(:home_address) { create(:address, applicant:, address_line_one: Faker::Address.street_name, location: "home", country_code: "DEU", country_name: "Germany") }

        it "does not fill the form with the existing address" do
          get_request
          expect(unescaped_response_body).not_to include(home_address.address_line_one)
          expect(unescaped_response_body).not_to include(home_address.address_line_two)
          expect(unescaped_response_body).not_to include(home_address.city)
          expect(unescaped_response_body).not_to include(home_address.county)
          expect(unescaped_response_body).not_to include(home_address.postcode)
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/home_address/enter_home_address" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_home_address_manual_path(legal_aid_application),
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
        context "when the linked application feature flag is enabled" do
          it "redirects to the next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        it "creates a home address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
          expect(home_address.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(home_address.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(home_address.city).to eq(address_params[:address][:city])
          expect(home_address.county).to eq(address_params[:address][:county])
          expect(home_address.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
          expect(home_address.country_code).to eq("GBR")
        end
      end

      context "with an invalid address" do
        before { address_params[:address].delete(:postcode) }

        it "renders the form again if validation fails" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("Enter your client's home address")
          expect(response.body).to include("Enter a postcode")
        end
      end

      context "with an already existing UK based home address" do
        before { create(:address, applicant:, location: "home", country_code: "GBR", country_name: "United Kingdom") }

        it "does not create a new address record" do
          expect { patch_request }.not_to change { applicant.addresses.count }
        end

        it "updates the current home address" do
          patch_request
          expect(home_address.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(home_address.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(home_address.city).to eq(address_params[:address][:city])
          expect(home_address.county).to eq(address_params[:address][:county])
          expect(home_address.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
        end
      end

      context "with an already existing non-UK home address" do
        before { create(:address, applicant:, location: "home", country_code: "DEU") }

        it "creates a new home address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
          expect(home_address.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(home_address.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(home_address.city).to eq(address_params[:address][:city])
          expect(home_address.county).to eq(address_params[:address][:county])
          expect(home_address.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
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
          expect(home_address.lookup_used).to be(true)
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
