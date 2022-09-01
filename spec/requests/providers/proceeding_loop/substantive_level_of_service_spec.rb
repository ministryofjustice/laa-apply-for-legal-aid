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
    end
  end
end
