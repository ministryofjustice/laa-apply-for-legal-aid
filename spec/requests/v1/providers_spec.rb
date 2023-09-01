require "rails_helper"

RSpec.describe "PATCH /v1/providers" do
  let(:provider) { create(:provider, cookies_enabled: nil) }
  let(:id) { provider.id }
  let(:action) { "" }
  let(:params) { { provider: { action: } } }

  describe "PATCH /v1/legal_aid_applications/:id" do
    subject(:request) { patch v1_provider_path(id), params: }

    context "when the provider accepts cookies" do
      let(:action) { "accept" }

      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "sets the cookies enabled attribute to true" do
        expect { request }.to change { provider.reload.cookies_enabled }.to(true)
      end

      it "adds the datetime to cookies_saved_at" do
        expect { request }.to change { provider.reload.cookies_saved_at }
      end
    end

    context "when the provider rejects cookies" do
      let(:action) { "reject" }

      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "sets the cookies enabled attribute to false" do
        expect { request }.to change { provider.reload.cookies_enabled }.to(false)
      end

      it "adds the datetime to cookies_saved_at" do
        expect { request }.to change { provider.reload.cookies_saved_at }
      end
    end

    context "when the provider does not exist" do
      let(:id) { SecureRandom.hex }

      it "returns http bad request" do
        request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the action is badly formed" do
      let(:action) { "abc" }

      it "returns http bad request" do
        request
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
