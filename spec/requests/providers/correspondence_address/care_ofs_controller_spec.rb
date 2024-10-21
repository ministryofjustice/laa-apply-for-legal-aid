require "rails_helper"

RSpec.describe Providers::CorrespondenceAddress::CareOfsController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, :with_correspondence_address) }
  let(:provider) { legal_aid_application.provider }
  let(:care_of) { "" }
  let(:care_of_first_name) { "" }
  let(:care_of_last_name) { "" }
  let(:care_of_organisation_name) { "" }

  describe "GET /providers/applications/:legal_aid_application_id/care_of" do
    subject(:get_request) { get providers_legal_aid_application_correspondence_address_care_of_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the care ofs page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Do you want to add a 'care of' recipient for your client's mail?")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/care_of" do
    subject(:patch_request) { patch providers_legal_aid_application_correspondence_address_care_of_path(legal_aid_application), params: }

    let(:submit_button) { {} }
    let(:params) do
      {
        address: {
          care_of:,
          care_of_first_name:,
          care_of_last_name:,
          care_of_organisation_name:,
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

      context "with 'Yes, a person' chosen" do
        let(:care_of) { "person" }
        let(:care_of_first_name) { "Simon" }
        let(:care_of_last_name) { "Smith" }

        it "saves Care Of" do
          patch_request
          expect(applicant.reload.address.care_of).to eq "person"
          expect(applicant.reload.address.care_of_first_name).to eq "Simon"
          expect(applicant.reload.address.care_of_last_name).to eq "Smith"
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with 'Yes, an organisation' chosen" do
        let(:care_of) { "organisation" }
        let(:care_of_organisation_name) { "Banbury Council" }

        it "saves Care Of" do
          patch_request
          expect(applicant.reload.address.care_of).to eq "organisation"
          expect(applicant.reload.address.care_of_organisation_name).to eq "Banbury Council"
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with 'no' chosen" do
        let(:care_of) { "no" }

        it "saves Care Of" do
          patch_request
          expect(applicant.reload.address.care_of).to eq "no"
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with no answer selected" do
        it "re-renders the form with the validation errors" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("Select if you want to add a 'care of' recipient for your client's email")
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end
      end
    end
  end
end
