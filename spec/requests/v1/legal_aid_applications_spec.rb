require "rails_helper"

RSpec.describe "GET /v1/legal_aid_applications" do
  let(:legal_aid_application) { create(:legal_aid_application, :with_everything, substantive_application_deadline_on: 1.day.ago) }
  let(:id) { legal_aid_application.id }

  describe "GET /v1/legal_aid_applications/:id" do
    subject(:get_request) { delete v1_legal_aid_application_path(id:) }

    context "when the application exists" do
      it "returns http success" do
        get_request
        expect(response).to have_http_status(:success)
      end

      it "sets the application to discarded" do
        expect { get_request }.to change { legal_aid_application.reload.discarded_at }
      end
    end

    context "when the application does not exist" do
      let(:id) { SecureRandom.hex }

      it "returns http not found" do
        get_request
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the application has a pre-existing scheduled mail" do
      let!(:scheduled_mailing) { create(:scheduled_mailing, legal_aid_application:) }

      it "clears any scheduled mailings" do
        expect { get_request }.to change { legal_aid_application.scheduled_mailings.first.cancelled_at }
      end
    end
  end
end
