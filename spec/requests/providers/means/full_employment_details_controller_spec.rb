require "rails_helper"

RSpec.describe Providers::Means::FullEmploymentDetailsController do
  let(:application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine) }
  let(:applicant) { application.applicant }
  let(:provider) { application.provider }
  let(:before_actions) { {} }
  let(:enable_hmrc_collection) { true }

  before { allow(Setting).to receive(:collect_hmrc_data?).and_return(enable_hmrc_collection) }

  describe "GET /providers/applications/:id/means/full_employment_details" do
    subject(:request) { get providers_legal_aid_application_means_full_employment_details_path(application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        before_actions
        login_as provider
        request
      end

      context "when HMRC collection is on" do
        context "when the no job data is returned" do
          let(:before_actions) { create(:hmrc_response, :nil_response, legal_aid_application_id: application.id, owner_id: applicant.id, owner_type: applicant.class) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the 'no data' message" do
            expect(response.body).to include(html_compare("HMRC has no record of your client's employment in the last 3 months"))
          end
        end

        context "when the HMRC response is pending" do
          let(:before_actions) { create(:hmrc_response, :processing, legal_aid_application_id: application.id, owner_id: applicant.id, owner_type: applicant.class) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the 'no data' message" do
            expect(response.body).to include(html_compare("HMRC has no record of your client's employment in the last 3 months"))
          end

          describe "Sending a message to Sentry" do
            let(:before_actions) do
              create(:hmrc_response, :processing, legal_aid_application_id: application.id, owner_id: applicant.id, owner_type: applicant.class)
              allow(Sentry).to receive(:capture_message)
            end

            it "sends the message to Sentry and is successful" do
              expect(response).to have_http_status(:ok)
              expect(Sentry).to have_received(:capture_message).with(/HMRC response still pending/)
            end
          end
        end

        context "when the applicant has multiple jobs" do
          let(:before_actions) do
            create(:hmrc_response, :multiple_employments_usecase1, legal_aid_application_id: application.id, owner_id: applicant.id, owner_type: applicant.class)
            create_list(:employment, 2, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class)
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the 'multiple job' message" do
            expect(response.body).to include(html_compare("HMRC found a record of your client's employment"))
            expect(response.body).to include(html_compare("HMRC says your client had more than one job in the last 3 months."))
          end
        end

        context "when applicant has no national insurance number" do
          let(:application) { create(:legal_aid_application, :with_applicant_no_nino) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct page content" do
            expect(response.body).to include(html_compare("We could not check your client's employment record with HMRC"))
          end
        end
      end

      context "when HMRC collection is off" do
        let(:enable_hmrc_collection) { false }

        context "and the applicant has a national insurance number" do
          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the 'no data' message" do
            expect(response.body).to include(html_compare("Enter details of your client's employment in the last 3 months"))
          end
        end

        context "and applicant has no national insurance number" do
          let(:application) { create(:legal_aid_application, :with_applicant_no_nino) }

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end

          it "displays the correct page content" do
            expect(response.body).to include(html_compare("Enter details of your client's employment in the last 3 months"))
          end
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/means/full_employment_details" do
    subject(:request) { patch providers_legal_aid_application_means_full_employment_details_path(application), params: params.merge(submit_button) }

    let(:full_employment_details) { Faker::Lorem.paragraph }
    let(:params) do
      {
        legal_aid_application: {
          full_employment_details:,
        },
      }
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "when form submitted with continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        it "updates legal aid application employment details" do
          request
          expect(application.reload.full_employment_details).to eq full_employment_details
        end

        context "when the application is using the bank upload journey" do
          let(:application) { create(:legal_aid_application, provider_received_citizen_consent: false) }

          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the application is not using the bank upload journey" do
          it "redirects to the next page" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when params are invalid" do
          let(:full_employment_details) { "" }

          it "displays error" do
            request
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.full_employment_details.blank"))
          end
        end
      end

      context "when form submitted with Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        context "when after success" do
          before { login_as provider }

          it "updates the legal_aid_application.full_employment_details" do
            request
            expect(application.reload.full_employment_details).to eq full_employment_details
          end

          it "redirects to the list of applications" do
            request
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
