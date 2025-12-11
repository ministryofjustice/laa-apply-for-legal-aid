require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")
RSpec.describe Test::DatastorePayloadsController do
  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    Rails.application.reload_routes!
  end

  after do
    allow(Rails).to receive(:env).and_call_original # unstub
    Rails.application.reload_routes!
  end

  let(:legal_aid_application) { create(:legal_aid_application, provider:) }
  let(:provider) { create(:provider) }

  describe "GET application_as_json" do
    context "when provider not authenticated" do
      before do
        get "/test/datastore_payloads/#{legal_aid_application.id}/application_as_json", headers: { "ACCEPT" => "application/json" }
      end

      it "is unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when provider authenticated" do
      before do
        login_as provider
        get "/test/datastore_payloads/#{legal_aid_application.id}/generated_json", headers: { "ACCEPT" => "application/json" }
      end

      it "renders JSON payload" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        expect(response.parsed_body)
          .to be_a(Hash)
          .and include("applicationReference" => legal_aid_application.application_ref)
      end
    end
  end

  describe "GET generated_json" do
    context "when provider not authenticated" do
      before do
        get "/test/datastore_payloads/#{legal_aid_application.id}/generated_json", headers: { "ACCEPT" => "application/json" }
      end

      it "is unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when provider authenticated" do
      before do
        login_as provider
        get "/test/datastore_payloads/#{legal_aid_application.id}/generated_json", headers: { "ACCEPT" => "application/json" }
      end

      it "renders JSON payload" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        expect(response.parsed_body)
          .to be_a(Hash)
          .and include("applicationReference" => legal_aid_application.application_ref)
      end
    end
  end

  describe "GET submit" do
    context "when provider not authenticated" do
      before do
        get "/test/datastore_payloads/#{legal_aid_application.id}/submit", headers: { "ACCEPT" => "application/json" }
      end

      it "is unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when provider authenticated" do
      before do
        login_as provider
      end

      context "when submission raises an ApiError" do
        before do
          stub_bad_request_datastore_submission
          get "/test/datastore_payloads/#{legal_aid_application.id}/submit", headers: { "HTTP_REFERER" => "/same-page" }
        end

        it "redirects back and flashes error" do
          expect(response)
            .to have_http_status(:redirect)
            .and redirect_to("/same-page")

          follow_redirect!

          expect(flash[:error]).to match("Datastore Submission Failed: status 400")
          expect(page).to have_content("Datastore Submission Failed")
        end
      end

      context "when submission is successful" do
        subject(:get_submit) do
          get "/test/datastore_payloads/#{legal_aid_application.id}/submit", headers: { "HTTP_REFERER" => "/same-page" }
        end

        before do
          stub_successful_datastore_submission
        end

        it "redirects back and flashes success" do
          get_submit

          expect(response)
            .to have_http_status(:redirect)
            .and redirect_to("/same-page")

          follow_redirect!

          expect(flash[:notice]).to match("Submitted application \"#{legal_aid_application.application_ref}\" to datastore. It was given an id of \"67359989-7268-47e7-b3f9-060ccff9b150\".")
          expect(page).to have_content("Submitted application")
        end

        it "persists the datastore_id against the legal aid application" do
          expect { get_submit }.to change { legal_aid_application.reload.datastore_id }.from(nil).to("67359989-7268-47e7-b3f9-060ccff9b150")
        end

        it "creates a datastore submission record" do
          expect { get_submit }.to change { legal_aid_application.reload.datastore_submissions.count }.from(0).to(1)
        end
      end

      context "when no referrer in headers" do
        before do
          stub_successful_datastore_submission
          get "/test/datastore_payloads/#{legal_aid_application.id}/submit"
        end

        it "redirects to fallback page" do
          expect(response)
            .to have_http_status(:redirect)
            .and redirect_to(authenticated_root_path)
        end
      end
    end
  end
end
