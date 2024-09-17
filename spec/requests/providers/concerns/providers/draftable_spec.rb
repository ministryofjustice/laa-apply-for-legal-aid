require "rails_helper"

RSpec.describe Providers::Draftable do
  # Using providers/applicants#update to thoroughly test draftable behaviour
  #  ^^ ideally we should be using an anonymous class or similar to test a mixin
  #
  describe "PATCH /providers/applications/:legal_aid_application_id/applicant_details" do
    subject(:patch_request) { patch providers_legal_aid_application_applicant_details_path(application), params: params.merge(submit_button) }

    let(:application) { create(:legal_aid_application) }
    let(:provider) { application.provider }
    let(:params) do
      {
        applicant: {
          first_name: "John",
          last_name: "Doe",
          "date_of_birth(1i)": "1981",
          "date_of_birth(2i)": "07",
          "date_of_birth(3i)": "11",
          changed_last_name: false,
        },
      }
    end

    before do
      login_as provider
    end

    context "when the Form is submitted using Continue button" do
      let(:submit_button) { { anything: "That is not draft_button" } }

      context "and the application is in draft" do
        let(:application) { create(:legal_aid_application, :draft) }

        it "redirects provider to next step of the submission" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_application_previous_references_path(application))
        end

        it "sets the application as no longer draft" do
          expect { patch_request }.to change { application.reload.draft? }.from(true).to(false)
        end
      end
    end

    context "when the Form is submitted using Save as draft button" do
      let(:submit_button) do
        { draft_button: "Save as draft" }
      end

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "creates a new applicant associated with the application" do
        expect { patch_request }.to change(Applicant, :count).by(1)

        new_applicant = application.reload.applicant
        expect(new_applicant).to be_instance_of(Applicant)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { application.reload.draft? }.from(false).to(true)
      end

      context "when the params are not valid" do
        let(:params) do
          {
            applicant: {
              first_name: "",
              last_name: "",
            },
          }
        end

        it "renders the form page displaying the errors" do
          patch_request

          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("applicant-first-name-field-error")
          expect(unescaped_response_body).to include("applicant-last-name-field-error")
        end

        it "does NOT create a new applicant" do
          expect { patch_request }.not_to change(Applicant, :count)
        end
      end

      context "when the there is partially valid input" do
        let(:params) do
          {
            applicant: {
              first_name: "",
              last_name: "Doe",
            },
          }
        end

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "creates a new applicant associated with the application" do
          expect { patch_request }.to change(Applicant, :count).by(1)

          new_applicant = application.reload.applicant
          expect(new_applicant).to be_instance_of(Applicant)
        end

        it "sets the application as draft" do
          expect { patch_request }.to change { application.reload.draft? }.from(false).to(true)
        end
      end
    end
  end
end
