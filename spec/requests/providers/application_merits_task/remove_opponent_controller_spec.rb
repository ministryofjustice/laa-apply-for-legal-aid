require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe RemoveOpponentController do
      let(:application) { create(:legal_aid_application) }
      let(:provider) { application.provider }
      let!(:opponent2) { create(:opponent, legal_aid_application: application) }

      before { login_as provider }

      describe "show GET /providers/applications/:legal_aid_application_id/remove_opponent/:id" do
        subject(:get_remove) { get providers_legal_aid_application_remove_opponent_path(application, opponent2) }

        it "displays the opponents details" do
          get_remove
          expect(response.body).to include(html_compare(opponent2.full_name))
        end
      end

      describe "update PATCH /providers/applications/:legal_aid_application_id/remove_opponent/:id" do
        subject(:submit_remove) { patch providers_legal_aid_application_remove_opponent_path(application, opponent2), params: }

        let(:params) do
          {
            binary_choice_form: {
              remove_opponent: radio_button,
            },
            legal_aid_application_id: application.id,
          }
        end

        context "when opponent is removed" do
          let(:radio_button) { "true" }

          it "deletes the opponent record" do
            expect { submit_remove }.to change { application.opponents.count }.by(-1)
          end

          it "redirects along the flow" do
            submit_remove
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when opponent is not removed" do
          let(:radio_button) { "false" }

          it "does not delete a record" do
            expect { submit_remove }.not_to change { application.opponents.count }
          end

          it "redirects along the flow" do
            submit_remove
            expect(response).to have_http_status(:redirect)
          end
        end

        context "with neither yes nor no specified" do
          let(:radio_button) { "" }

          it "does not delete a record" do
            expect { submit_remove }.not_to change { application.opponents.count }
          end

          it "re-renders the page" do
            submit_remove
            expect(response).to have_http_status(:ok)
            expect(unescaped_response_body).to include("Are you sure you want to remove #{opponent2.full_name} from the application?")
          end
        end
      end
    end
  end
end
