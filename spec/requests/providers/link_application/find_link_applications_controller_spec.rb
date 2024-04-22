require "rails_helper"

RSpec.describe Providers::LinkApplication::FindLinkApplicationsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/find_link_case" do
    subject(:get_request) { get providers_legal_aid_application_link_application_find_link_application_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the find link application page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("What is the LAA reference of the application you want to link to?")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_application/find_link_case" do
    subject(:patch_request) { patch providers_legal_aid_application_link_application_find_link_application_path(legal_aid_application), params: }

    let(:params) do
      {
        linked_application: {
          search_laa_reference:,
        },
      }
    end
    let(:search_laa_reference) { "L-123-456" }

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the searched application is found and submitted" do
        before { create(:legal_aid_application, provider:, application_ref: "L-123-456", merits_submitted_at: Date.yesterday) }

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)

          expect(flash).to be_empty
        end
      end

      context "when the searched application belongs to the same firm but is not submitted" do
        before { create(:legal_aid_application, provider:, application_ref: "L-123-456") }

        it "renders the same page with a notification banner" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("Submit L-123-456 if you want to link to it.")
        end
      end

      context "when the search application is not found" do
        let(:search_laa_reference) { "L-999-999" }

        it "renders the same page with a notification banner" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("We could not find an application with the LAA reference of L-999-999.")
        end
      end

      context "when the search value is empty" do
        let(:search_laa_reference) { "" }

        it "renders the same page with an error message" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("Enter the LAA reference of the application you want to link to.")
        end
      end
    end
  end
end
