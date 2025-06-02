require "rails_helper"

RSpec.describe Providers::MeansReportsController do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_everything,
      :with_proceedings,
      :with_cfe_v6_result,
      :assessment_submitted,
      explicit_proceedings: %i[da002 da006],
      application_ref: "L-123-456",
    )
  end

  describe "GET /providers/applications/:legal_aid_application_id/means_report" do
    subject(:request) do
      get providers_legal_aid_application_means_report_path(legal_aid_application)
    end

    before do
      allow(Grover).to receive(:new).and_call_original
      login_provider
      request
    end

    context "when authenticated and authorised" do
      let(:login_provider) { login_as legal_aid_application.provider }

      it "renders the means report PDF, with inline css", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(Grover)
          .to have_received(:new)
          .with(a_string_including("L-123-456"), hash_including(:style_tag_options))
      end
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when not authorised" do
      let(:login_provider) { login_as create(:provider) }

      it_behaves_like "an authenticated provider from a different firm"
    end
  end
end
