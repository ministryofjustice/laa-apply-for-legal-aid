require "rails_helper"

RSpec.describe Test::GenerateErrorController do
  describe "GET trapped_error" do
    it "calls the Alert Manager" do
      expect(AlertManager).to receive(:capture_exception)
      get "/test/trapped_error"
      expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
    end
  end

  describe "untrapped error" do
    it "propagates the error" do
      expect {
        get "/test/untrapped_error"
      }.to raise_error RuntimeError, "Untrapped Test Error generated"
    end
  end
end
