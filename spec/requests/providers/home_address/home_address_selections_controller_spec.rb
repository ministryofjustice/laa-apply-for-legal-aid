require "rails_helper"

RSpec.describe Providers::HomeAddress::HomeAddressSelectionsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/home_address/home_address_selection" do
    subject(:get_request) { get providers_legal_aid_application_home_address_home_address_selection_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when a postcode has been entered before", :vcr do
        let(:postcode) { "SW1H 9EA" }
        let(:building_number_name) { "" }
        let!(:address) { create(:address, location: "home", postcode:, applicant:, building_number_name:) }

        it "performs an address lookup with the provided postcode" do
          expect(AddressLookupService)
            .to receive(:call).with(address.postcode).and_call_original

          get_request
        end

        it "renders the home address selection page" do
          get_request

          expect(response).to be_successful
          expect(unescaped_response_body).to match("Select your client's home address")
        end

        context "but the lookup does not return any valid results" do
          let(:postcode) { "XX1 1XX" }

          it "renders the address selection page" do
            get_request

            expect(response).to be_successful
            expect(unescaped_response_body).to match("No address found")
          end
        end

        context "and a building number has been added" do
          describe "so only one address is remaining after filtering" do
            let(:building_number_name) { "100" }

            it "renders home address confirmation page" do
              get_request

              expect(response).to be_successful
              expect(unescaped_response_body).to match("Confirm your client's home address")
            end
          end

          describe "so several addresses are remaining after filtering" do
            let(:building_number_name) { "1" }

            it "renders home address selection page" do
              get_request

              expect(response).to be_successful
              expect(unescaped_response_body).to match("Select your client's home address")
            end

            it "correctly filters the addresses" do
              get_request

              expect(response.body).to include("102 Petty France", "100 Petty France")
              expect(response.body).not_to include("84 Petty France", "98 Petty France")
            end
          end
        end
      end

      context "when no postcode have been entered yet" do
        before { get providers_legal_aid_application_home_address_home_address_lookup_path(legal_aid_application) }

        it "redirects to the postcode entering page" do
          get_request
          expect(response).to redirect_to(providers_legal_aid_application_home_address_home_address_lookup_path(back: true))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/home_address/home_address_selections" do
    subject(:patch_request) { patch providers_legal_aid_application_home_address_home_address_selection_path(legal_aid_application), params: }

    let(:address_list) do
      [
        { lookup_id: "11", address_line_one: "1", address_line_two: "FAKE ROAD", city: "TEST CITY", postcode: "AA1 1AA" },
        { lookup_id: "12", address_line_one: "2", address_line_two: "FAKE ROAD", city: "TEST CITY", postcode: "AA1 1AA" },
        { lookup_id: "13", address_line_one: "3", address_line_two: "FAKE ROAD", city: "TEST CITY", postcode: "AA1 1AA" },
      ]
    end
    let(:selected_address) { address_list.sample }
    let(:lookup_id) { selected_address[:lookup_id] }
    let(:postcode) { selected_address[:postcode] }
    let(:submit_button) { { continue_button: "Continue" } }
    let(:params) do
      {
        address_selection: {
          list: address_list.map(&:to_json),
          postcode:,
          lookup_id:,
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

      context "when no address was selected from the list" do
        let(:lookup_id) { "" }

        before { create(:address, location: "home", postcode: "XX11XX", applicant:) }

        it "does not create a new address record" do
          expect { patch_request }.not_to change(Address, :count)
        end

        it "renders the address selection page" do
          patch_request

          expect(response).to be_successful
          expect(unescaped_response_body).to match("Select your client's home address")
          expect(unescaped_response_body).to match("There is a problem")
        end
      end

      it "creates a new home address record associated with the applicant" do
        expect { patch_request }.to change { applicant.reload.addresses.count }.by(1)
        expect(applicant.home_address.address_line_one).to eq(selected_address[:address_line_one])
        expect(applicant.home_address.lookup_id).to eq(lookup_id)
        expect(applicant.home_address.country_code).to eq("GBR")
      end

      it "records that the lookup service was used" do
        patch_request
        expect(applicant.home_address.lookup_used).to be(true)
      end

      context "when linked_applications flag is disabled" do
        before { Setting.update!(linked_applications: false) }

        it "redirects successfully to the next step" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path)
        end
      end

      context "when linking_applications flag is enabled" do
        before { Setting.update!(linked_applications: true) }

        it "redirects successfully to the next step" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_application_copy_case_invitation_path)
        end
      end

      context "when an address already exists" do
        before { create(:address, applicant:) }

        it "does not create a new address record" do
          expect { patch_request }.not_to change { applicant.addresses.count }
        end

        it "updates the current address" do
          patch_request
          expect(applicant.home_address.address_line_one).to eq(selected_address[:address_line_one])
          expect(applicant.home_address.lookup_id).to eq(lookup_id)
        end
      end

      context "when a single home address was displayed" do
        let(:params) do
          {
            address_selection: {
              address_line_one: "1",
              address_line_two: "FAKE ROAD",
              city: "TEST CITY",
              postcode: "AA1 1AA",
              lookup_post_code: "AA1 1AA",
            },
          }.merge(submit_button)
        end

        it "creates a new home address record associated with the applicant" do
          expect { patch_request }.to change { applicant.reload.addresses.count }.by(1)
          expect(applicant.home_address.address_line_one).to eq("1")
          expect(applicant.home_address.address_line_two).to eq("FAKE ROAD")
          expect(applicant.home_address.city).to eq("TEST CITY")
          expect(applicant.home_address.postcode).to eq("AA11AA")
          expect(applicant.home_address.country_code).to eq("GBR")
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
