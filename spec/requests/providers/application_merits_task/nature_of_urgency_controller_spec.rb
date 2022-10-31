require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe NatureOfUrgencyController do
      let(:legal_aid_application) { create(:legal_aid_application) }
      let(:login_provider) { login_as legal_aid_application.provider }

      describe "GET /providers/applications/:legal_aid_application_id/nature_of_urgency" do
        subject(:nature_of_urgency) { get providers_legal_aid_application_nature_of_urgency_path(legal_aid_application) }

        before do
          login_provider
          nature_of_urgency
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end
      end
    end
  end
end
