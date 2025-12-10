require "rails_helper"

RSpec.describe Providers::CorrespondenceAddress::ChoicesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/where_to_send_correspondence" do
    subject(:get_request) { get providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the correspondence address choice page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Where should we send your client's correspondence?")
      end
    end

    context "when the state is initiated" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :initiated) }

      it "fires the enter_applicant_details event and changes the state to entering_applicant_details" do
        login_as provider
        expect { get_request }.to change { legal_aid_application.reload.state }.from("initiated").to("entering_applicant_details")
      end
    end

    context "when the state is entering_applicant_details" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :entering_applicant_details) }

      it "skips the enter_applicant_details event" do
        login_as provider
        expect { get_request }.not_to change { legal_aid_application.reload.state }
      end
    end
  end

  describe "PATCH/providers/applications/:legal_aid_application_id/where_to_send_correspondence" do
    subject(:patch_request) { patch providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application), params: }

    let(:correspondence_address_choice) { "home" }
    let(:submit_button) { {} }
    let(:params) do
      {
        applicant: {
          correspondence_address_choice:,
        },
      }.merge(submit_button)
    end

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "with an invalid choice" do
        let(:correspondence_address_choice) { "invalid-choice" }

        it "re-renders the form with the validation errors" do
          patch_request
          expect(response).to have_http_status(:ok)
          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("Select where we should send your client's correspondence")
        end
      end

      context "with a valid choice" do
        it "saves the choice" do
          patch_request
          expect(applicant.reload.correspondence_address_choice).to eq("home")
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "when checking answers" do
          let(:legal_aid_application) do
            create(:legal_aid_application, :with_applicant, :checking_applicant_details).tap do |laa|
              laa.applicant.update!(correspondence_address_choice: "home")
            end
          end

          context "and the choice has not changed" do
            let(:correspondence_address_choice) { "home" }

            it "redirects to check providers answers page" do
              patch_request
              expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
            end
          end

          context "and the choice has changed" do
            let(:correspondence_address_choice) { "office" }

            it "redirects to next page" do
              patch_request
              expect(response).to redirect_to(providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application))
            end
          end
        end
      end

      context "with form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
