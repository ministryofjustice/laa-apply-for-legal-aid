require "rails_helper"

RSpec.describe Providers::MeritsReportsController do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_everything,
      :assessment_submitted,
      proceedings: [proceeding],
      application_ref: "L-123-456",
    )
  end

  let(:proceeding) { build(:proceeding, :da001, chances_of_success:) }
  let(:chances_of_success) { build(:chances_of_success) }

  let(:merits_task_list) do
    create(:legal_framework_merits_task_list, :da001, legal_aid_application:)
  end

  describe "GET /providers/applications/:legal_aid_application_id/merits_report" do
    subject(:request) do
      get providers_legal_aid_application_merits_report_path(legal_aid_application)
    end

    before do
      stub_merits_task_list(legal_aid_application:, merits_task_list:)
      allow(Grover).to receive(:new).and_call_original
      login_provider
      request
    end

    context "when authenticated and authorised" do
      let(:login_provider) { login_as legal_aid_application.provider }

      it "renders the merits report PDF", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(Grover)
          .to have_received(:new)
          .with(a_string_including("L-123-456"), style_tag_options: [content: Rails.root.join("app/assets/builds/application.css").read])
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

  describe "GET /providers/applications/:legal_aid_application_id/merits_report?debug" do
    subject(:request) do
      get providers_legal_aid_application_merits_report_path(legal_aid_application, debug: true)
    end

    before do
      stub_merits_task_list(legal_aid_application:, merits_task_list:)
      allow(Grover).to receive(:new).and_call_original
      login_provider
      request
    end

    context "when authenticated and authorised" do
      let(:login_provider) { login_as legal_aid_application.provider }

      it "renders the merits report PDF", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("text/html; charset=utf-8")
        expect(Grover).not_to have_received(:new)
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

  def stub_merits_task_list(legal_aid_application:, merits_task_list:)
    allow(LegalFramework::MeritsTasksService)
      .to receive(:call)
      .with(legal_aid_application)
      .and_return(merits_task_list)
  end
end
