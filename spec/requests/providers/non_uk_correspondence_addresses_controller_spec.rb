require "rails_helper"

RSpec.describe Providers::NonUkCorrespondenceAddressesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }
  let(:address) { applicant.address }
  let(:country) { "China" }
  let(:address_line_one) { "Maple Leaf Education Building" }
  let(:address_line_two) { "No. 13 Baolong 1st Road" }
  let(:city) { "Longgang District" }
  let(:county) { "Shenzhen City, Guangdong Province" }
  let(:address_params) do
    {
      non_uk_correspondence_address:
        {
          address_line_one:,
          address_line_two:,
          city:,
          county:,
          country:,
        },
    }
  end

  describe "GET /providers/applications/:legal_aid_application_id/non_uk_correspondence_address/edit" do
    subject(:get_request) { get providers_legal_aid_application_non_uk_correspondence_address_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include("Enter your client's overseas correspondence address")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/non_uk_correspondence_address" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_non_uk_correspondence_address_path(legal_aid_application),
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

        it "creates an address record" do
          expect { patch_request }.to change { applicant.addresses.count }.by(1)
          expect(address.address_line_one).to eq(address_params[:non_uk_correspondence_address][:address_line_one])
          expect(address.address_line_two).to eq(address_params[:non_uk_correspondence_address][:address_line_two])
          expect(address.city).to eq(address_params[:non_uk_correspondence_address][:city])
          expect(address.county).to eq(address_params[:non_uk_correspondence_address][:county])
          expect(address.postcode).to be_nil
        end
      end

      context "with an invalid address" do
        before { address_params[:non_uk_correspondence_address].delete(:country) }

        it "renders the form again if validation fails" do
          patch_request
          expect(unescaped_response_body).to include("Enter a country")
        end
      end

      context "with an already existing address" do
        before { create(:address, applicant:) }

        it "does not create a new address record" do
          expect { patch_request }.not_to change { applicant.addresses.count }
        end

        it "updates the current address" do
          patch_request
          expect(address.address_line_one).to eq(address_line_one)
          expect(address.address_line_two).to eq(address_line_two)
          expect(address.city).to eq(city)
          expect(address.county).to eq(county)
          expect(address.country).to eq(country)
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
