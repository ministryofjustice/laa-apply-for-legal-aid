require "rails_helper"

RSpec.describe "AuthController" do
  let(:params) do
    {
      "message" => "provider_error",
      "origin" => origin_path,
      "strategy" => "true_layer",
    }
  end

  describe "GET failure" do
    subject(:get_request) { get "/auth/failure", params: }

    context "with origin from citizens/banks" do
      let(:origin_path) { citizens_banks_path }

      it "redirects to citizens_consent_path" do
        get_request
        expect(response).to redirect_to citizens_consent_path(auth_failure: true)
      end
    end

    context "with origin from elsewhere" do
      let(:origin_path) { root_path }

      it "redirects to access denied" do
        get_request
        expect(response).to redirect_to error_path(:access_denied)
      end
    end

    context "with no origin" do
      it "redirects to access denied" do
        get "/auth/failure"
        expect(response).to redirect_to error_path(:access_denied)
      end
    end
  end
end
