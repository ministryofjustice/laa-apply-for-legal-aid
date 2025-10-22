require "rails_helper"

RSpec.describe Providers::LinkApplication::ConfirmLinksController do
  let(:linked_application) { create(:linked_application, lead_application: create(:legal_aid_application, :with_applicant, linked_application_completed:), associated_application: create(:legal_aid_application), link_type_code:) }
  let(:legal_aid_application) { linked_application.associated_application }
  let(:lead_application) { linked_application.lead_application }
  let(:provider) { legal_aid_application.provider }
  let(:link_type_code) { "FC_LEAD" }
  let(:linked_application_completed) { nil }

  describe "GET /providers/applications/:legal_aid_application_id/link_application/confirm_link" do
    subject(:get_request) do
      get providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application)
    end

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "renders page with expected heading" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_css(
          "h1",
          text: "Search result",
        )
      end

      context "when navigating with the back button and the linked application task task has previously been completed" do
        let(:linked_application_completed) { true }

        it "resets linked_application" do
          expect(legal_aid_application.reload.linked_application_completed).to be false
        end
      end
    end

    context "when the target application is associated to a different lead application" do
      let(:lead_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_proceedings,
               provider: legal_aid_application.provider,
               application_ref: "L-111-222",
               id: "f1b3c2ef-1e93-4d4e-a983-643598f1eaf4",
               merits_submitted_at: Date.yesterday)
      end
      let(:target_application) do
        create(:legal_aid_application,
               :with_applicant,
               :with_proceedings,
               provider: legal_aid_application.provider,
               application_ref: "L-333-444",
               id: "42edab70-1584-4fc6-9a42-7e3eae3ca726",
               merits_submitted_at: Date.yesterday)
      end
      let(:legal_aid_application) do
        create(:legal_aid_application, id: "02d46b69-60e9-4b0a-8df2-84e92bdb45c4")
      end

      before do
        create(:linked_application,
               lead_application:,
               associated_application: target_application,
               link_type_code: "FC_LEAD")
        create(:linked_application,
               lead_application:,
               target_application:,
               associated_application: legal_aid_application,
               link_type_code: "FC_LEAD")
        login_as provider
        get_request
      end

      it "renders page with target data in summary block and lead application in hidden drop down section" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_css("dd", text: "L-333-444")
        expect(page).to have_css("div.govuk-details__text", visible: :hidden, text: "#{lead_application.application_ref}, #{lead_application.applicant.full_name}") # works but not very precise
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_application/confirm_link" do
    subject(:patch_request) { patch providers_legal_aid_application_link_application_confirm_link_path(legal_aid_application), params: }

    let(:params) do
      {
        linked_application: {
          confirm_link:,
        },
      }
    end
    let(:confirm_link) { "true" }

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "when the Continue button is pressed" do
        context "when Yes is chosen" do
          context "when link type is family" do
            it "sets the correct flash message" do
              patch_request
              expect(flash[:hash][:heading_text]).to match(/You've made a family link/)
            end
          end

          context "when link type is legal" do
            let(:link_type_code) { "LEGAL" }

            it "sets the correct flash message" do
              patch_request
              expect(flash[:hash][:heading_text]).to eql("You've linked this application to #{lead_application.application_ref}")
            end
          end
        end

        context "when No, carry on without linking is chosen" do
          let(:confirm_link) { "false" }

          it "sets confirm_link to false" do
            patch_request
            expect(linked_application.reload.confirm_link).to be false
          end

          it "does not set a success flash message" do
            patch_request
            expect(flash).to be_empty
          end
        end

        context "when No, I want to link to a different case is chosen" do
          let(:confirm_link) { "No" }

          it "sets confirm_link to stay nil" do
            patch_request
            expect(linked_application.confirm_link).to be_nil
          end

          it "does not set a success flash message" do
            patch_request
            expect(flash).to be_empty
          end

          context "when no radio button is chosen" do
            let(:confirm_link) { nil }

            it "re-renders the form with the validation errors" do
              patch_request
              expect(unescaped_response_body).to include("Select if you want to link to the application")
            end
          end
        end

        context "when form submitted with Save as draft button" do
          context "when Yes is chosen" do
            let(:params) do
              {
                draft_button: "Save and come back later",
                linked_application: {
                  confirm_link:,
                },
              }
            end

            it "redirects to the list of applications" do
              patch_request
              expect(response.body).to redirect_to in_progress_providers_legal_aid_applications_path
            end

            it "sets the application as draft" do
              expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
            end
          end

          context "when the application has not yet been linked" do
            let(:params) do
              {
                draft_button: "Save and come back later",
              }
            end

            it "redirects to the list of applications" do
              patch_request
              expect(response.body).to redirect_to in_progress_providers_legal_aid_applications_path
            end

            it "sets the application as draft" do
              expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
            end
          end
        end
      end
    end
  end
end
