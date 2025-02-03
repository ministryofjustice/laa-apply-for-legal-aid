require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::VaryOrderController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da002]) }
  let(:login_provider) { login_as legal_aid_application.provider }
  let(:smtl) { create(:legal_framework_merits_task_list, :da002_as_applicant, legal_aid_application:) }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA002") }

  describe "GET /providers/applications/merits_task_list/:merits_task_list_id/vary_order" do
    subject(:get_vary_order) { get providers_merits_task_list_vary_order_path(proceeding) }

    before do
      login_provider
      get_vary_order
    end

    it "renders show with ok" do
      expect(response).to have_http_status(:ok).and render_template("providers/proceeding_merits_task/vary_order/show")
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when authenticated as a different provider" do
      let(:login_provider) { login_as create(:provider) }

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/merits_task_list/:merits_task_list_id/vary_order" do
    subject(:patch_vary_order) do
      patch(
        providers_merits_task_list_vary_order_path(proceeding),
        params: params.merge(button_clicked),
      )
    end

    let(:params) do
      { proceeding_merits_task_vary_order: { details: } }
    end

    let(:details) { Faker::Lorem.sentence }
    let(:draft_button) { { draft_button: "Save as draft" } }
    let(:button_clicked) { {} }
    let(:vary_order) { proceeding.reload.vary_order }

    before do
      allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
      login_provider
    end

    context "when details are provided" do
      let(:details) { "reason for new application to vary the order" }

      it "creates a new vary_order with the values entered" do
        expect { patch_vary_order }.to change(ProceedingMeritsTask::VaryOrder, :count).by(1)
        expect(proceeding.reload.vary_order.details).to eql("reason for new application to vary the order")
      end

      it "sets the vary_order task to complete" do
        patch_vary_order
        expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:DA002, :vary_order)
      end

      it "redirects" do
        patch_vary_order
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when details are not provided" do
      let(:details) { "" }

      it "renders show with ok" do
        patch_vary_order
        expect(response).to have_http_status(:ok).and render_template("providers/proceeding_merits_task/vary_order/show")
      end

      it "does not set the vary_order task to complete" do
        patch_vary_order
        expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA002, :vary_order)
      end
    end

    context "when all previous application merits tasks are completed" do
      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :nature_of_urgency)
      end

      it "redirects to the first proceeding merits task" do
        patch_vary_order
        expect(response).to redirect_to(providers_merits_task_list_chances_of_success_path(proceeding))
      end
    end

    context "when all previous application and proceeding merits tasks are completed for DA002" do
      before do
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :nature_of_urgency)
        legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA002, :chances_of_success)
      end

      it "redirects to the providers merits task list page" do
        patch_vary_order
        expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
      end
    end

    context "when a previous record exists and posting with new details" do
      before do
        create(:vary_order, proceeding:, details: "my first detailed reason")
      end

      let(:params) do
        { proceeding_merits_task_vary_order: { details: "my second detailed reason" } }
      end

      it "overwrites the values" do
        expect { patch_vary_order }.to change { proceeding.reload.vary_order.details }.from("my first detailed reason").to("my second detailed reason")
      end
    end

    context "when save as draft selected" do
      let(:button_clicked) { draft_button }

      it "redirects to provider draft endpoint" do
        patch_vary_order
        expect(response).to redirect_to provider_draft_endpoint
      end

      it "does not set the task to complete" do
        patch_vary_order
        expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA002, :vary_order)
      end
    end
  end
end
