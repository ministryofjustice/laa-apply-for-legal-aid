require "rails_helper"

RSpec.describe Providers::AuthController do
  context "when an oauth error is returned" do
    subject(:patch_request) do
      get providers_auth_failure_path({ message: "error_message", origin: "fake_origin", strategy: "entra_id" })
    end

    it "redirects to the error page with access denied" do
      expect(patch_request).to redirect_to(error_path(:access_denied))
    end
  end
end
