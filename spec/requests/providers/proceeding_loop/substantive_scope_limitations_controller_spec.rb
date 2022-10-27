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

  before do
    allow(Setting).to receive(:enable_mini_loop?).and_return(true) # TODO: Remove when the mini-loop feature flag is removed
    allow(Setting).to receive(:enable_loop?).and_return(true) # TODO: Remove when the loop feature flag is removed
  end

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
            expect(response.body).to redirect_to(providers_legal_aid_application_limitations_path(application_id))
          end
        end

        context "when the form is invalid" do
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
      end
    end
  end
end
