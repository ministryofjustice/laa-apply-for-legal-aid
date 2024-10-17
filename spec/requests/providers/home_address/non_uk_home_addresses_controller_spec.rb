require "rails_helper"

RSpec.describe Providers::HomeAddress::NonUkHomeAddressesController, :vcr do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }
  let(:address) { applicant.address }
  let(:home_address) { applicant.home_address }
  let(:country_code) { "CHN" }
  let(:country_name) { "China" }
  let(:address_line_one) { "Maple Leaf Education Building" }
  let(:address_line_two) { "No. 13 Baolong 1st Road" }
  let(:city) { "Longgang District" }
  let(:county) { "Shenzhen City, Guangdong Province" }
  let(:address_params) do
    {
      non_uk_home_address:
        {
          address_line_one:,
          address_line_two:,
          city:,
          county:,
          country_name:,
        },
    }
  end

  describe "GET /providers/applications/:legal_aid_application_id/home_address/non_uk_home_address/edit" do
    subject(:get_request) { get providers_legal_aid_application_home_address_non_uk_home_address_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include("Enter your client's overseas home address")
      end

      context "when the applicant has an existing overseas home address" do
        it "displays the home address" do
          create(:address, applicant:, location: "home", address_line_one: "Konigstrasse 1", address_line_two: "Stuttgart", country_name: "Germany", country_code: "DEU")
          get_request
          expect(response.body).to include("Konigstrasse 1", "Stuttgart")
          expect(response.body).to include("value=\"Germany\" checked=\"checked\"")
        end
      end

      context "when the applicant has an existing uk home address" do
        it "does not display the home address" do
          create(:address, applicant:, location: "home", address_line_one: "1 Kings Street", address_line_two: "London", country_name: "United Kingdom", country_code: "GBR")
          get_request
          expect(response.body).not_to include("1 Kings Street", "London")
          expect(response.body).not_to include("value=\"United Kingdom\" checked=\"checked\"")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/home_address/non_uk_home_address" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_home_address_non_uk_home_address_path(legal_aid_application),
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
        it "creates a home address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
          expect(home_address.location).to eq("home")
          expect(home_address.address_line_one).to eq(address_params[:non_uk_home_address][:address_line_one])
          expect(home_address.address_line_two).to eq(address_params[:non_uk_home_address][:address_line_two])
          expect(home_address.city).to eq(address_params[:non_uk_home_address][:city])
          expect(home_address.county).to eq(address_params[:non_uk_home_address][:county])
          expect(home_address.country_code).to eq(country_code)
          expect(home_address.postcode).to be_nil
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with an invalid address" do
        before { address_params[:non_uk_home_address].delete(:country_name) }

        it "renders the form again if validation fails" do
          patch_request
          expect(unescaped_response_body).to include("Search for and select a country")
        end
      end

      context "with an already existing correspondence address but no home address" do
        before do
          create(:address, applicant:, location: "correspondence")
        end

        it "creates a new address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
        end

        it "does not update the correspondence address" do
          expect { patch_request }.not_to change(applicant, :address)
        end

        it "updates the current home address" do
          patch_request
          expect(home_address.location).to eq("home")
          expect(home_address.address_line_one).to eq(address_line_one)
          expect(home_address.address_line_two).to eq(address_line_two)
          expect(home_address.city).to eq(city)
          expect(home_address.county).to eq(county)
          expect(home_address.country_code).to eq(country_code)
          expect(home_address.country_name).to eq(country_name)
          expect(home_address.postcode).to be_nil
        end
      end

      context "with an already existing correspondence address and home address" do
        before do
          create(:address, applicant:, location: "correspondence")
        end

        context "with an overseas home address" do
          it "does not create a new address record" do
            create(:address, applicant:, location: "home", country_code: "DEU")
            expect { patch_request }.not_to change { applicant.addresses.count }
          end
        end

        context "with a UK home address" do
          it "does not create a new address record" do
            create(:address, applicant:, location: "home", country_code: "GBR")
            expect { patch_request }.to change { applicant.addresses.count }.by(1)
          end
        end

        it "does not update the correspondence address" do
          expect { patch_request }.not_to change(applicant, :address)
        end

        it "updates the current home address" do
          patch_request
          expect(home_address.location).to eq("home")
          expect(home_address.address_line_one).to eq(address_line_one)
          expect(home_address.address_line_two).to eq(address_line_two)
          expect(home_address.city).to eq(city)
          expect(home_address.county).to eq(county)
          expect(home_address.country_code).to eq(country_code)
          expect(home_address.country_name).to eq(country_name)
          expect(home_address.postcode).to be_nil
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
