require "rails_helper"

RSpec.describe "SubstantiveScopeLimitationsController", :vcr do
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

  describe "GET /providers/applications/:legal_aid_application_id/substantive_scope_limitations/:proceeding_id" do
    subject(:get_ss) { get "/providers/applications/#{application_id}/substantive_scope_limitations/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_ss }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_ss
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

  describe "POST /providers/applications/:legal_aid_application_id/substantive_scope_limitations/:proceeding_id" do
    subject(:post_ssl) { patch "/providers/applications/#{application_id}/substantive_scope_limitations/#{proceeding_id}", params: }

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
      before { post_ssl }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        post_ssl
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "when the form is valid" do
          it "redirects to next page" do
            expect(response).to have_http_status(:redirect)
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

            it "shows an error if no scope limitation is selected" do
              expect(response.body).to include(I18n.t("providers.proceeding_loop.select_a_scope_limitation_error"))
            end
          end

          context "when a mandatory limitation note is missing" do
            let(:application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_delegated_functions_on_proceedings,
                     explicit_proceedings: %i[se013a],
                     df_options: { SE013A: [10.days.ago, 10.days.ago] },
                     substantive_application_deadline_on: 10.days.from_now)
            end

            let(:params) do
              {
                proceeding: {
                  scope_codes: %w[APL13],
                  meaning_APL13: "High Court-limited steps (resp)",
                  description_APL13: "Limited to representation as respondent on an appeal to the High Court, limited to",
                  limitation_note_APL13: "",
                },
              }
            end

            it "ticks the affected box and shows an error" do
              expect(response.body).to include(I18n.t("providers.proceeding_loop.enter_limitation_note_error", scope_limitation: "High Court-limited steps (resp)")).twice
                                         .and include('value="APL13" checked="checked"')
            end
          end
        end
      end
    end
  end
end
