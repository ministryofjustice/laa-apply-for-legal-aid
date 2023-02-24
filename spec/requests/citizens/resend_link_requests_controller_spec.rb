require "rails_helper"

RSpec.describe Citizens::ResendLinkRequestsController do
  let(:applicant) do
    build(
      :applicant,
      first_name: "Test",
      last_name: "User",
      email: "test@example.com",
    )
  end

  let(:legal_aid_application) { build(:legal_aid_application, applicant:) }

  let(:citizen_access_token) do
    create(:citizen_access_token, legal_aid_application:, token: "token-1")
  end

  describe "GET /citizens/resend_link/:id" do
    subject(:request) do
      get citizens_resend_link_request_path(citizen_access_token.token)
    end

    it "returns ok" do
      request
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /citizens/resend_link/:id" do
    subject(:request) do
      patch citizens_resend_link_request_path(citizen_access_token.token)
    end

    before do
      allow(SecureRandom).to receive(:uuid).and_return("token-2")
      allow(ScheduledMailing).to receive(:send_now!)
      request
    end

    it "returns ok and sends an email to the applicant with a new link", :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(ScheduledMailing).to have_received(:send_now!).with(
        mailer_klass: ResendLinkRequestMailer,
        mailer_method: :notify,
        legal_aid_application_id: legal_aid_application.id,
        addressee: "test@example.com",
        arguments: [
          legal_aid_application.application_ref,
          "test@example.com",
          citizens_legal_aid_application_url("token-2"),
          "Test User",
        ],
      )
    end
  end
end
