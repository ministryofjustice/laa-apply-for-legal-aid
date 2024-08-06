require "rails_helper"

module Providers
  RSpec.describe ProviderBaseController do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:applicant) { legal_aid_application.applicant }
    let(:provider) { legal_aid_application.provider }
    let(:provider_in_same_firm) { create(:provider, firm: provider.firm) }
    let(:provider_in_different_firm) { create(:provider) }

    context "when making GET requests" do
      describe "GET /providers/applications/:legal_aid_application_id/address/edit" do
        before do
          login_as logged_in_provider
          get providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application)
        end

        context "when provider who created legal aid application" do
          let(:logged_in_provider) { provider }

          it "is successful" do
            expect(response).to be_successful
          end
        end

        context "when provider in same firm" do
          let(:logged_in_provider) { provider_in_same_firm }

          it "is successful" do
            expect(response).to be_successful
          end
        end

        context "when provider in different firm" do
          let(:logged_in_provider) { provider_in_different_firm }

          it "is redirected to the access denied page" do
            expect(response).to redirect_to(error_path(:access_denied))
          end
        end
      end
    end

    describe "PATCH /providers/applications/:legal_aid_application_id/correspondence_address/enter_correspondence_address" do
      before do
        login_as logged_in_provider
        patch providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application), params: address_params
      end

      context "when provider who created legal aid application" do
        let(:logged_in_provider) { provider }

        it "is successful" do
          expect(response).to redirect_to(providers_legal_aid_application_correspondence_address_care_of_path)
        end
      end

      context "when provider in same firm" do
        let(:logged_in_provider) { provider_in_same_firm }

        it "is successful" do
          expect(response).to redirect_to(providers_legal_aid_application_correspondence_address_care_of_path)
        end
      end

      context "when provider in different firm" do
        let(:logged_in_provider) { provider_in_different_firm }

        it "is redirected to the access denied page" do
          expect(response).to redirect_to(error_path(:access_denied))
        end
      end

      def address_params
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
    end
  end
end
