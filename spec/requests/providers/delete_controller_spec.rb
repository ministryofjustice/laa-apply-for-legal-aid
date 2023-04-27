require "rails_helper"

RSpec.describe Providers::DeleteController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_everything, substantive_application_deadline_on: 1.day.ago) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/delete" do
    subject(:show_delete_view) { get providers_legal_aid_application_delete_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { show_delete_view }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        show_delete_view
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include("Are you sure you want to delete this application?")
      end

      it "displays the application data" do
        expect(unescaped_response_body).to include(legal_aid_application.application_ref)
      end
    end
  end

  describe "DELETE /admin/legal_aid_applications/:legal_aid_application_id/destroy" do
    subject(:submit_delete_request) { delete providers_legal_aid_application_delete_path(legal_aid_application) }

    before { login_as provider }

    context "when the application has no pre-existing scheduled mails" do
      it "sets the application to discarded" do
        expect { submit_delete_request }.to change { legal_aid_application.reload.discarded_at }
      end

      it "returns http found" do
        submit_delete_request
        expect(response).to have_http_status(:found)
      end
    end

    context "when the application has a pre-existing scheduled mail" do
      before { create(:scheduled_mailing, legal_aid_application:) }

      it "clears any scheduled mailings" do
        expect { submit_delete_request }.to change { legal_aid_application.scheduled_mailings.first.cancelled_at }
      end
    end
  end
end
