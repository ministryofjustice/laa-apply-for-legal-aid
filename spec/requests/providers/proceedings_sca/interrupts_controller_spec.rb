require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::InterruptsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:current_proceeding) { create(:proceeding, :pb007) }
  let(:provider) { legal_aid_application.provider }
  let(:display) { "supervision" }

  before { legal_aid_application.proceedings << current_proceeding }

  describe "GET /providers/applications/:id/interrupt/:type" do
    subject(:get_request) { get providers_legal_aid_application_sca_interrupt_path(legal_aid_application, display) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "shows text for a supervision order and a button to select a different proceeding" do
        expect(response.body).to include("For special children act, a supervision order cannot be varied, discharged or extended")
        expect(response.body).to include("Select a different proceeding or matter type")
      end

      context "when passed an unknown type" do
        let(:display) { "jedi" }

        it "shows default text and a button to select a different proceeding" do
          expect(response.body).to include("You cannot choose a special children act proceeding if it has not been issued")
          expect(response.body).to include("Select a different proceeding or matter type")
        end
      end
    end
  end

  describe "DELETE /providers/applications/:id/interrupt/:current_proceeding/:type" do
    subject(:delete_request) { delete "/providers/applications/#{legal_aid_application.id}/interrupt/#{display}" }

    context "when the provider is not authenticated" do
      before { delete_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        delete_request
      end

      it "redirects to the proceeding types path" do
        expect(response).to redirect_to providers_legal_aid_application_proceedings_types_path
      end

      it "deletes the current proceeding" do
        expect { current_proceeding.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
