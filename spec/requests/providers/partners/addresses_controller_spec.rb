require "rails_helper"

RSpec.describe Providers::Partners::AddressesController do
  let(:partner) { create(:partner) }
  let(:legal_aid_application) { partner.legal_aid_application }
  let(:provider) { legal_aid_application.provider }
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

  describe "GET /providers/applications/:legal_aid_application_id/partner_address" do
    subject(:get_partner_address) { get providers_legal_aid_application_partners_address_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_partner_address }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns success" do
        get_partner_address
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Enter the partner's correspondence address")
      end

      context "when an address has already been added for the partner" do
        let(:partner) { create(:partner, :with_address) }

        it "fills the form with the existing address" do
          get_partner_address
          expect(unescaped_response_body).to include(partner.address_line_one)
          expect(unescaped_response_body).to include(partner.address_line_two)
          expect(unescaped_response_body).to include(partner.city)
          expect(unescaped_response_body).to include(partner.county)
          expect(unescaped_response_body).to include(partner.postcode)
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/partner_address" do
    subject(:patch_partner_address) do
      patch(
        providers_legal_aid_application_partners_address_path(legal_aid_application),
        params: address_params.merge(submit_button),
      )
    end

    let(:submit_button) { {} }

    context "when the provider is not authenticated" do
      before { patch_partner_address }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "with a valid address" do
        it "redirects successfully to the next step" do
          patch_partner_address
          expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path)
        end

        it "adds the address to the partner" do
          patch_partner_address
          partner.reload
          expect(partner.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(partner.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(partner.city).to eq(address_params[:address][:city])
          expect(partner.county).to eq(address_params[:address][:county])
          expect(partner.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
        end
      end

      context "with an invalid address" do
        before { address_params[:address].delete(:postcode) }

        it "renders the form again if validation fails" do
          patch_partner_address
          expect(unescaped_response_body).to include("Enter the partner's correspondence address")
          expect(response.body).to include("Enter a postcode")
        end
      end

      context "with an already existing address" do
        before { create(:partner, :with_address) }

        it "updates the current address" do
          patch_partner_address
          partner.reload
          expect(partner.address_line_one).to eq(address_params[:address][:address_line_one])
          expect(partner.address_line_two).to eq(address_params[:address][:address_line_two])
          expect(partner.city).to eq(address_params[:address][:city])
          expect(partner.county).to eq(address_params[:address][:county])
          expect(partner.postcode).to eq(address_params[:address][:postcode].delete(" ").upcase)
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
          patch_partner_address
          expect(partner.reload.lookup_used).to be(true)
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_partner_address
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_partner_address }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
