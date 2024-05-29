require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe InvolvedChildrenController do
      let(:application) { create(:legal_aid_application) }
      let(:provider) { application.provider }

      describe "new: GET /providers/applications/:legal_aid_application_id/involved_children/new" do
        subject(:get_request) { get new_providers_legal_aid_application_involved_child_path(application) }

        context "when authenticated" do
          before { login_as provider }

          it "returns success" do
            get_request
            expect(response).to have_http_status(:ok)
          end

          it "displays the form to add new children" do
            get_request
            expect(response.body).to include("Enter details of the children involved in this application")
            expect(response.body).to include("Full name")
            expect(response.body).to include("Date of birth")
          end
        end

        context "when unauthenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/involved_children/:involved_child_id" do
        subject(:get_request) { get providers_legal_aid_application_involved_child_path(application, child) }

        let(:child) { create(:involved_child, legal_aid_application: application) }

        context "when authenticated" do
          before { login_as provider }

          it "returns success" do
            get_request
            expect(response).to have_http_status(:ok)
          end

          it "displays child details" do
            get_request
            expect(response.body).to include(html_compare(child.full_name))
          end
        end

        context "when unauthenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "update: PATCH providers/applications/:legal_aid_application_id/involved_children/:involved_child_id" do
        subject(:patch_request) { patch providers_legal_aid_application_involved_child_path(application, child), params: }

        let(:child) { create(:involved_child, legal_aid_application: application) }
        let(:new_full_name) { "#{child.full_name} Junior" }

        let(:params) do
          { application_merits_task_involved_child: {
            full_name: new_full_name,
            "date_of_birth(3i)": "4",
            "date_of_birth(2i)": "6",
            "date_of_birth(1i)": "2020",
          } }
        end

        context "when authenticated" do
          before { login_as provider }

          context "with valid parameters" do
            it "updates the child record" do
              patch_request
              expect(child.reload.full_name).to eq new_full_name
              expect(child.reload.date_of_birth).to eq Date.new(2020, 6, 4)
            end

            it "redirects" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end

            context "with trailing whitespaces" do
              let(:new_full_name) { "  John    Doe  " }

              it "removes excess whitespaces" do
                patch_request
                expect(child.reload.full_name).to eq "John Doe"
              end
            end
          end

          context "with invalid params" do
            let(:new_full_name) { "" }

            it "does not update the child record" do
              expect { patch_request }.not_to change(child, :full_name)
            end

            it "renders the show page" do
              patch_request
              expect(response.body).to include(html_compare(child.full_name))
            end
          end
        end
      end
    end
  end
end
