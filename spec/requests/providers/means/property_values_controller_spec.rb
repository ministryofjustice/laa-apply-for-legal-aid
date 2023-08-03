require "rails_helper"

RSpec.describe Providers::Means::PropertyValuesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  describe "GET /providers/applications/:id/means/property_value" do
    subject { get providers_legal_aid_application_means_property_value_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as legal_aid_application.provider
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include("How much is your client's home worth?")
      end
    end
  end

  describe "PATCH /providers/applications/:id/means/property_value" do
    subject { patch providers_legal_aid_application_means_property_value_path(legal_aid_application), params: params.merge(submit_button) }

    let(:params) do
      {
        legal_aid_application: { property_value: },
        legal_aid_application_id: legal_aid_application.id,
      }
    end

    let(:property_value) { "123,456.78" }

    context "when the provider is authenticated" do
      before do
        login_as legal_aid_application.provider
        subject
      end

      context "when continue button is pressed" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        context "when a property value is entered" do
          context "when property is mortgaged" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }

            it "redirects to the outstanding mortgage question" do
              expect(response).to redirect_to providers_legal_aid_application_means_outstanding_mortgage_path(legal_aid_application)
            end
          end

          context "when property is owned outright" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_owned_outright) }

            it "redirects to the shared question" do
              expect(response).to redirect_to providers_legal_aid_application_means_shared_ownership_path(legal_aid_application)
            end
          end

          context "with valid values" do
            it "records the value in the legal aid legal_aid_application table" do
              legal_aid_application.reload
              expect(legal_aid_application.property_value).to be_within(0.01).of(123_456.78)
            end
          end
        end

        context "when a property value is not entered" do
          let(:property_value) { "" }

          it "shows an error message" do
            expect(response.body).to include("govuk-error-summary__title")
          end

          it "does not record the value in the legal aid application table" do
            legal_aid_application.reload
            expect(legal_aid_application.property_value).to be_nil
          end
        end
      end

      context "when Save as draft button is pressed" do
        let(:submit_button) do
          {
            draft_button: "Save as draft",
          }
        end

        context "when a property value is entered" do
          context "when property is mortgaged" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }

            it "redirects to the outstanding mortgage question" do
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end

          context "when property is owned outright" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_owned_outright) }

            it "redirects provider to provider's applications page" do
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end

          context "with valid values" do
            it "records the value in the legal aid legal_aid_application table" do
              legal_aid_application.reload
              expect(legal_aid_application.property_value).to be_within(0.01).of(123_456.78)
            end
          end
        end

        context "when a property value is not entered" do
          let(:property_value) { "" }

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
