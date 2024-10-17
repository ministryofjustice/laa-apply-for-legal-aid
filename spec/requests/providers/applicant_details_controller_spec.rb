require "rails_helper"

RSpec.describe Providers::ApplicantDetailsController do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/applicant_details" do
    subject(:get_request) { get "/providers/applications/#{application_id}/applicant_details" }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      it "returns http success" do
        get_request
        expect(response).to have_http_status(:ok)
      end

      context "and has already got applicant info" do
        let(:applicant) { create(:applicant) }
        let(:application) { create(:legal_aid_application, applicant:) }

        it "display first_name" do
          get_request
          expect(unescaped_response_body).to include(applicant.first_name)
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/applicant_details" do
    let(:params) do
      {
        applicant: {
          first_name: "John",
          last_name: "Doe",
          national_insurance_number: "AA 12 34 56 C",
          "date_of_birth(1i)": "1981",
          "date_of_birth(2i)": "07",
          "date_of_birth(3i)": "11",
          email: Faker::Internet.email,
          changed_last_name: "false",
        },
      }
    end

    context "when the provider is authenticated" do
      subject(:patch_request) do
        patch providers_legal_aid_application_applicant_details_path(application), params:
      end

      before do
        login_as provider
      end

      context "with form submitted using Continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        it "creates a new applicant associated with the application" do
          expect { patch_request }.to change(Applicant, :count).by(1)

          new_applicant = application.reload.applicant
          expect(new_applicant).to be_instance_of(Applicant)
        end

        context "when applicant details has trailing white spaces" do
          let(:params) do
            {
              applicant: {
                first_name: "  John  ",
                last_name: "   Doe",
                national_insurance_number: "AA 12 34 56 C",
                "date_of_birth(1i)": "1999",
                "date_of_birth(2i)": "07",
                "date_of_birth(3i)": "11",
                email: Faker::Internet.email,
                changed_last_name: "false",
              },
            }
          end

          context "when first name or last name has excess whitespaces" do
            it "strips and trims whitespaces from applicant details" do
              patch_request
              applicant = application.reload.applicant
              expect(applicant.first_name).to eq "John"
              expect(applicant.last_name).to eq "Doe"
            end
          end
        end

        context "when the application is in draft" do
          let(:application) { create(:legal_aid_application, :draft) }

          it "sets the application as no longer draft" do
            expect { patch_request }.to change { application.reload.draft? }.from(true).to(false)
          end
        end

        context "when the params are not valid" do
          let(:params) do
            {
              applicant: {
                first_name: "",
                last_name: "Doe",
                national_insurance_number: "AA 12 34 56 C",
                "date_of_birth(1i)": "1981",
                "date_of_birth(2i)": "07",
                "date_of_birth(3i)": "11",
                email: Faker::Internet.email,
              },
            }
          end

          it "renders the form page displaying the errors" do
            patch_request

            expect(unescaped_response_body).to include("There is a problem")
            expect(unescaped_response_body).to include("Enter first name")
          end

          it "does NOT create a new applicant" do
            expect { patch_request }.not_to change(Applicant, :count)
          end
        end
      end

      context "with form submitted using Save as draft button" do
        subject(:draft_request) do
          patch providers_legal_aid_application_applicant_details_path(application), params: params.merge(submit_button)
        end

        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          draft_request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { draft_request }.to change { application.reload.draft? }.from(false).to(true)
        end
      end

      context "when dates contain alpha characters" do
        let(:params) do
          {
            applicant: {
              first_name: "",
              last_name: "Doe",
              national_insurance_number: "AA 12 34 56 C",
              "date_of_birth(1i)": "1981",
              "date_of_birth(2i)": "6s",
              "date_of_birth(3i)": "11sa",
              email: Faker::Internet.email,
            },
          }
        end

        it "errors" do
          patch_request
          expect(unescaped_response_body).to include("There is a problem")
          expect(unescaped_response_body).to include("Enter a valid date of birth")
        end
      end
    end
  end
end
