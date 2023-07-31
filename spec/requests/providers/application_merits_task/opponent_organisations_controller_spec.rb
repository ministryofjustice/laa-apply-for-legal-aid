require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentOrganisationsController, :vcr do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "new: GET /providers/applications/:legal_aid_application_id/opponent_organisations/new" do
        subject(:get_new_opponent) { get new_providers_legal_aid_application_opponent_organisation_path(legal_aid_application) }

        context "when authenticated" do
          before do
            login_provider
            get_new_opponent
          end

          it "returns success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the form to add new opponent organisations" do
            expect(response.body).to include("Organisation name")
            expect(response.body).to include("Organisation type")
          end
        end

        context "when unauthenticated" do
          before { get_new_opponent }

          it_behaves_like "a provider not authenticated"
        end
      end
    end
  end
end
