require "rails_helper"

RSpec.describe "FinalHearingsController" do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/final_hearings/:proceeding_id/:work_type" do
    subject(:get_final_hearing) { get "/providers/applications/#{application_id}/final_hearings/#{proceeding_id}/#{work_type}" }

    let(:work_type) { "substantive" }

    context "when the provider is not authenticated" do
      before { get_final_hearing }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_final_hearing
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(response.body).to include("Has the proceeding been listed for a final contested hearing?")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/final_hearings/:proceeding_id/:work_type" do
    subject(:patch_final_hearing) { patch "/providers/applications/#{application_id}/final_hearings/#{proceeding_id}/#{work_type}", params: }

    let(:work_type) { :emergency }
    let(:params) do
      {
        final_hearing: {
          listed: false,
          details: "reasons for not listing",
        },
      }
    end

    context "when the provider is not authenticated" do
      before { patch_final_hearing }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        patch_final_hearing
      end

      context "when the work_type is substantive" do
        let(:work_type) { "substantive" }

        context "when the Continue button is pressed" do
          let(:submit_button) { { continue_button: "Continue" } }

          it "redirects to next page" do
            expect(response.body).to redirect_to(providers_legal_aid_application_substantive_scope_limitation_path(application_id))
          end

          context "when the parameters are invalid" do
            let(:params) do
              {
                final_hearing: {
                  listed: nil,
                },
              }
            end

            it "returns http_success" do
              expect(response).to have_http_status(:ok)
            end

            it "the response includes the error message" do
              expect(response.body).to include("Select yes if the proceeding has been listed for a final hearing")
            end
          end

          context "when checking answers" do
            let(:application) do
              create(
                :legal_aid_application,
                :with_applicant_and_address_lookup,
                :checking_applicant_details,
                :with_proceedings,
                :with_delegated_functions_on_proceedings,
                explicit_proceedings: %i[da001 se013],
                df_options: { DA001: [10.days.ago, 10.days.ago], SE013: nil },
                substantive_application_deadline_on: 10.days.from_now,
              ).reload
            end

            it "redirects to check provider answers page" do
              expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(application_id))
            end
          end
        end
      end
    end
  end
end
