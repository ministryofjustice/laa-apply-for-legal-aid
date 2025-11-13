require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::Submission do
  let(:uri) { "#{Rails.configuration.x.data_access_api.url}/applications" }
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

    context "with successful response" do
      before do
        stub_successful_datastore_submission
      end

      it "makes one external call" do
        call
        expect(a_request(:post, uri)).to have_been_made.times(1)
      end

      it "returns expected response" do
        expect(call).to eq("message" => "Submission created successfully")
      end
    end

    context "with successful response with no body (current situation at time of writing)" do
      before do
        stub_successful_datastore_submission_without_body
      end

      it "returns empty hash" do
        expect(call).to eq({})
      end
    end

    context "with bad request response" do
      before do
        stub_bad_request_datastore_submission
      end

      it "raises error" do
        expect { call }.to raise_error(described_class::ApiError, "Datastore Submission Failed: status 400, body {\"type\":\"about:blank\",\"title\":\"Bad request\",\"status\":400,\"detail\":\"Check your request was valid\",\"instance\":\"/api/v0/applications\"}")
      end
    end

    context "with unauthorised response" do
      before do
        stub_unauthorized_datastore_submission
      end

      it "raises error" do
        expect { call }.to raise_error(described_class::ApiError, "Datastore Submission Failed: status 401, body {\"type\":\"about:blank\",\"title\":\"Unauthorized\",\"status\":401,\"detail\":\"Check your request was has been authorized\",\"instance\":\"/api/v0/applications\"}")
      end
    end

    context "with forbidden response" do
      before do
        stub_forbidden_datastore_submission
      end

      it "raises error" do
        expect { call }.to raise_error(described_class::ApiError, "Datastore Submission Failed: status 403, body {\"type\":\"about:blank\",\"title\":\"Forbidden\",\"status\":403,\"detail\":\"Check your request was has been authenticated\",\"instance\":\"/api/v0/applications\"}")
      end
    end

    context "with internal server error response" do
      before do
        stub_internal_server_error_datastore_submission
      end

      it "raises error" do
        expect { call }.to raise_error(described_class::ApiError, "Datastore Submission Failed: status 500, body {\"type\":\"about:blank\",\"title\":\"Internal server error\",\"status\":500,\"detail\":\"An unexpected application error has occurred.\",\"instance\":\"/api/v0/applications\"}")
      end
    end
  end
end
