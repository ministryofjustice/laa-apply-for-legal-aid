require "rails_helper"

RSpec.describe "provider invalid schedules" do
  describe "GET providers/invalid_schedules" do
    let(:provider) { create(:provider) }

    before do
      login_as provider
      get providers_invalid_schedules_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
      expect(unescaped_response_body).to include(I18n.t("providers.invalid_schedules.show.h1-heading"))
    end

    it "logs the provider out" do
      expect(session["signed_out"]).to be true
    end
  end
end
