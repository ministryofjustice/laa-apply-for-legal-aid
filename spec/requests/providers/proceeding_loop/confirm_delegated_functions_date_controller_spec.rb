require "rails_helper"

RSpec.describe "ConfirmDelegatedFunctionsDateController", :vcr, type: :request do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           df_options: { DA001: 10.days.ago })
  end
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  before { allow(Setting).to receive(:enable_mini_loop?).and_return(true) } # TODO: Remove when the mini-loop feature flag is removed

  describe "GET /providers/applications/:legal_aid_application_id/confirm_delegated_functions_date/:proceeding_id" do
    subject(:get_cdf) { get "/providers/applications/#{application_id}/confirm_delegated_functions_date/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_cdf }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_cdf
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(response.body).to include("The date you said you used delegated functions is over one month old.")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/confirm_delegated_functions_date/:proceeding_id" do
    subject(:post_df) { patch "/providers/applications/#{application_id}/confirm_delegated_functions_date/#{proceeding_id}", params: }

    let(:params) { { binary_choice_form: { confirm_delegated_functions_date: confirm } } }
    let(:confirm) { "true" }

    context "when the provider is not authenticated" do
      before { post_df }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "and the user selected yes" do
          it "redirects to next page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_limitations_path(application_id))
          end
        end

        context "and the user selected no" do
          let(:confirm) { "false" }

          it "redirects back to the df page" do
            post_df
            expect(response.body).to redirect_to(providers_legal_aid_application_delegated_function_path(application_id))
          end
        end

        context "and the user selected nothing" do
          let(:confirm) { nil }

          before { post_df }

          it "returns http_success" do
            expect(response).to have_http_status(:ok)
          end

          it "the response includes the error message" do
            expect(response.body).to include(I18n.t("providers.confirm_delegated_functions_dates.show.error"))
          end
        end
      end
    end
  end
end
