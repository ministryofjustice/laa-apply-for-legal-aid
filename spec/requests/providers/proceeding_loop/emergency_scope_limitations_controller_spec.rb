require "rails_helper"

RSpec.describe "EmergencyScopeLimitationsController", :vcr do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: %i[se013],
           df_options: { SE013: [10.days.ago, 10.days.ago] },
           substantive_application_deadline_on: 10.days.from_now)
  end
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/emergency_scope_limitations/:proceeding_id" do
    subject(:get_es) { get "/providers/applications/#{application_id}/emergency_scope_limitations/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_es }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_es
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Child arrangements order (contact)")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/emergency_scope_limitations/:proceeding_id" do
    subject(:post_esl) { patch "/providers/applications/#{application_id}/emergency_scope_limitations/#{proceeding_id}", params: }

    let(:params) do
      {
        proceeding: {
          scope_codes: ["", "FM007"],
          meaning_FM007: "Blood Tests or DNA Tests",
          description_FM007: "Limited to all steps up to and including the obtaining of blood tests or DNA tests and thereafter a solicitor's report.",
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_esl }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        post_esl
      end

      context "when the form is valid" do
        context "when the Continue button is pressed" do
          let(:submit_button) { { continue_button: "Continue" } }

          it "redirects to next page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context "when the form is invalid" do
        context "when no scope limitation is selected" do
          let(:params) do
            {
              proceeding: {
                scope_codes: [""],
                meaning_FM007: "Blood Tests or DNA Tests",
                description_FM007: "Limited to all steps up to and including the obtaining of blood tests or DNA tests and thereafter a solicitor's report.",
              },
            }
          end

          it "shows an error" do
            expect(response.body).to include(I18n.t("providers.proceeding_loop.select_a_scope_limitation_error"))
          end
        end

        context "when a mandatory hearing date is missing" do
          let(:params) do
            {
              proceeding: {
                scope_codes: %w[CV027],
                meaning_CV027: "Hearing/Adjournment",
                description_CV027: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                hearing_date_CV027: "",
              },
            }
          end

          it "ticks the affected box and shows an error" do
            expect(response.body).to include(I18n.t("providers.proceeding_loop.enter_valid_hearing_date_error", scope_limitation: "Hearing/Adjournment")).twice
                                       .and include('value="CV027" checked="checked"')
          end
        end
      end
    end
  end
end
