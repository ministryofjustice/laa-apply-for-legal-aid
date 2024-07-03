require "rails_helper"

RSpec.describe "SubstantiveDefaultsController", :vcr do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: %i[da001],
           df_options: { DA001: [10.days.ago, 10.days.ago] },
           substantive_application_deadline_on: 10.days.from_now)
  end
  let(:application_id) { application.id }
  let(:proceeding_id) { application.proceedings.first.id }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/substantive_defaults/:proceeding_id" do
    subject(:get_sd) { get "/providers/applications/#{application_id}/substantive_defaults/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_sd }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_sd
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
        expect(response.body).to include("Do you want to use the default level of service and scope for the substantive application?")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/substantive_defaults/:proceeding_id" do
    subject(:post_sd) { patch "/providers/applications/#{application_id}/substantive_defaults/#{proceeding_id}", params: }

    before { allow(DelegatedFunctionsDateService).to receive(:call).and_return(true) }

    let(:params) do
      {
        proceeding: {
          accepted_substantive_defaults: false,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_sd }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        post_sd
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "when the provider accepts the defaults" do
          let(:params) do
            {
              proceeding: {
                accepted_substantive_defaults: true,
              },
            }
          end

          it "redirects to next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the provider does not accept the defaults" do
          it "redirects to next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the application is a Special Childrens Act application" do
          let(:application) { create(:legal_aid_application, :with_multiple_sca_proceedings) }
          let(:params) do
            {}
          end

          it "redirects to next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when checking answers" do
          let(:application) do
            create(:legal_aid_application,
                   :with_proceedings,
                   :checking_applicant_details,
                   :with_delegated_functions_on_proceedings,
                   explicit_proceedings: %i[da001],
                   df_options: { DA001: [10.days.ago, 10.days.ago] },
                   substantive_application_deadline_on: 10.days.from_now)
          end

          before { application.reload }

          context "when the date is within the last month" do
            it "continues through the sub flow" do
              expect(response).to redirect_to(providers_legal_aid_application_substantive_level_of_service_path(application_id))
            end
          end
        end
      end
    end
  end
end
