require "rails_helper"
RSpec.describe "OmniAuth initializers" do
  describe "OmniAuth.config.on_failure handler" do
    subject(:handler) { OmniAuth.config.on_failure }

    before do
      env["omniauth.error"] = error
      env["omniauth.error.type"] = error_type
    end

    let(:env) do
      Rack::MockRequest.env_for(
        "/auth/entra_id/callback",
        "rack.session" => {},
      )
    end

    let(:error) do
      OmniAuth::Strategies::OpenIDConnect::CallbackError.new(
        error: error_type,
        error_reason: error_reason,
        error_uri: "",
      )
    end

    context "with a CSRF state mismatch error" do
      let(:error_type) { :csrf_detected }
      let(:error_reason) { "Invalid 'state' parameter" }

      it "logs the exception" do
        expect(Rails.logger).to receive(:warn).with("Omniauth CSRF state mismatch error: #{error}")

        handler.call(env)
      end

      it "does not capture the exception" do
        expect(AlertManager).not_to receive(:capture_exception)

        handler.call(env)
      end

      it "redirects to the failure endpoint" do
        response = handler.call(env)
        expect(response[0]).to eq(302)
        expect(response[1]["Location"]).to include("/auth/failure?message=csrf_detected")
      end
    end

    context "with another OmniAuth error" do
      let(:error_type) { :invalid_credentials }
      let(:error_reason) { "Invalid credentials supplied" }

      it "logs the exception" do
        expect(Rails.logger).to receive(:warn).with("Omniauth error: #{error}")

        handler.call(env)
      end

      it "captures the exception" do
        expect(AlertManager).to receive(:capture_exception).with(error)

        handler.call(env)
      end

      it "redirects to the failure endpoint" do
        response = handler.call(env)
        expect(response[0]).to eq(302)
        expect(response[1]["Location"]).to include("/auth/failure?message=invalid_credentials")
      end
    end
  end
end
