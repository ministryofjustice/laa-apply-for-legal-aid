require "rails_helper"

RSpec.describe Providers::Partners::AddressSelectionsController do
  let(:partner) { create(:partner) }
  let(:legal_aid_application) { partner.legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partner_address_selections/edit" do
    subject(:get_address_selection) { get providers_legal_aid_application_partners_address_selection_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_address_selection }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when a postcode has been entered before", :vcr do
        let(:postcode) { "SW1H 9EA" }
        let(:partner) { create(:partner, postcode:) }

        it "performs an address lookup with the provided postcode" do
          expect(AddressLookupService).to receive(:call).with(partner.postcode).and_call_original

          get_address_selection
        end

        it "renders the address selection page" do
          get_address_selection

          expect(response).to be_successful
          expect(unescaped_response_body).to match("Select an address")
          expect(unescaped_response_body).to match("[1-9]{1}[0-9]? addresses found")
        end

        context "but the lookup does not return any valid results" do
          let(:postcode) { "XX1 1XX" }
          let(:form_heading) { "Enter the partner's correspondence address" }
          let(:error_message) { "We could not find any addresses for that postcode. Enter the address manually." }

          it "renders the manual address selection page" do
            get_address_selection

            expect(response).to be_successful
            expect(unescaped_response_body).to match(form_heading)
            expect(unescaped_response_body).to match(error_message)
          end
        end
      end

      context "when no postcode has been entered yet" do
        before { get providers_legal_aid_application_partners_address_lookup_path(legal_aid_application) }

        it "redirects to the postcode entering page" do
          get_address_selection
          expect(response).to redirect_to(providers_legal_aid_application_partners_address_lookup_path(back: true))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partner_address_selections" do
    subject(:patch_address_selection) { patch providers_legal_aid_application_partners_address_selection_path(legal_aid_application), params: }

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
      before { patch_address_selection }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when no address was selected from the list" do
        let(:lookup_id) { "" }

        it "renders the address selection page again with errors" do
          patch_address_selection

          expect(response).to be_successful
          expect(unescaped_response_body).to match("Select an address from the list")
          expect(unescaped_response_body).to match("Select an address")
          expect(unescaped_response_body).to match("[1-9]{1}[0-9]? addresses found")
        end
      end

      it "updates the address fields for the partner" do
        patch_address_selection
        partner.reload
        expect(partner.address_line_one).to eq(selected_address[:address_line_one])
        expect(partner.lookup_id).to eq(lookup_id)
      end

      it "redirects to next submission step" do
        patch_address_selection

        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
      end

      it "records that the lookup service was used" do
        patch_address_selection
        expect(partner.reload.lookup_used).to be(true)
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_address_selection
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_address_selection }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
