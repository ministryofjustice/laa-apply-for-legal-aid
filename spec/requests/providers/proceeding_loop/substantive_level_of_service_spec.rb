require "rails_helper"

RSpec.describe "SubstantiveLevelOfServiceController", :vcr, type: :request do
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

  before do
    allow(Setting).to receive(:enable_mini_loop?).and_return(true) # TODO: Remove when the mini-loop feature flag is removed
    allow(Setting).to receive(:enable_loop?).and_return(true) # TODO: Remove when the loop feature flag is removed
  end

  describe "GET /providers/applications/:legal_aid_application_id/substantive_level_of_service/:proceeding_id" do
    subject(:get_slos) { get "/providers/applications/#{application_id}/substantive_level_of_service/#{proceeding_id}" }

    context "when the provider is not authenticated" do
      before { get_slos }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_slos
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the proceeding header" do
        expect(response.body).to include("Proceeding 1")
        expect(response.body).to include("Inherent jurisdiction high court injunction")
      end

      context "when the proceeding has only one possible level of service" do
        it "displays a message that the level of service cannot be changed" do
          expect(response.body).to include("You cannot change the default level of service for the substantive application for this proceeding")
        end
      end

      context "when the proceeding has more than one possible level of service" do
        let(:application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: %i[se013],
                 df_options: { SE013: [10.days.ago, 10.days.ago] },
                 substantive_application_deadline_on: 10.days.from_now)
        end

        it "asks the user to select a level of service" do
          expect(response.body).to include("For the substantive application, select the level of service")
        end
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/substantive_level_of_service/:proceeding_id" do
    subject(:post_slos) { patch "/providers/applications/#{application_id}/substantive_level_of_service/#{proceeding_id}", params: }

    let(:params) do
      {
        proceeding: {
          substantive_level_of_service: 3,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { post_slos }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        post_slos
      end

      context "when the Continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects to next page" do
          expect(response.body).to redirect_to(providers_legal_aid_application_limitations_path(application_id))
        end
      end
    end
  end
end
