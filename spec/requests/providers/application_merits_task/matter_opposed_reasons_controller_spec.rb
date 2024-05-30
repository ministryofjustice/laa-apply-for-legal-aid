require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::MatterOpposedReasonsController do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_proceedings,
      explicit_proceedings: %i[da001 se003],
    )
  end

  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/matter_opposed_reason" do
    subject(:request) do
      get providers_legal_aid_application_matter_opposed_reason_path(legal_aid_application)
    end

    it "returns ok" do
      login_as provider

      request

      expect(response).to have_http_status(:ok)
    end

    context "when the application has a matter opposition" do
      it "displays the reason" do
        _matter_opposition = create(
          :matter_opposition,
          legal_aid_application:,
          reason: "This is a matter opposed reason",
        )
        login_as provider

        request

        expect(page).to have_field(
          "application_merits_task_matter_opposition[reason]",
          with: "This is a matter opposed reason",
        )
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/matter_opposed_reason" do
    subject(:request) do
      patch providers_legal_aid_application_matter_opposed_reason_path(legal_aid_application),
            params: params.merge(button_clicked)
    end

    let(:merits_task_list) do
      create(
        :legal_framework_merits_task_list,
        :da001_as_defendant_se003,
        legal_aid_application:,
      )
    end

    let(:params) { { application_merits_task_matter_opposition: { reason: } } }
    let(:reason) { "A reason to oppose the matter" }
    let(:button_clicked) { {} }
    let(:draft_button) { { draft_button: "Save as draft" } }
    let(:continue_button) { { continue_button: "Save and continue" } }

    before do
      allow(LegalFramework::MeritsTasksService)
        .to receive(:call)
        .with(legal_aid_application)
        .and_return(merits_task_list)
    end

    context "when the provider continues" do
      let(:button_clicked) { continue_button }

      it "updates the reason, completes the task, and redirects to the next page" do
        login_as provider

        request

        expect(legal_aid_application.matter_opposition.reason).to eq(reason)
        expect(matter_opposed_task.state).to eq(:complete)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider saves as draft" do
      let(:button_clicked) { draft_button }

      it "updates the reason, does not complete the task, and redirects to the applications page" do
        login_as provider

        request

        expect(legal_aid_application.matter_opposition.reason).to eq(reason)
        expect(matter_opposed_task.state).to eq(:not_started)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the application has a matter opposition" do
      let(:reason) { "An updated reason!" }

      it "updates the reason" do
        matter_opposition = create(
          :matter_opposition,
          legal_aid_application:,
          reason: "This is a matter opposed reason",
        )
        login_as provider

        request

        expect(ApplicationMeritsTask::MatterOpposition.count).to eq(1)
        expect(matter_opposition.reload.reason).to eq(reason)
      end
    end

    context "when the form is invalid" do
      let(:reason) { nil }

      it "displays an error and does not update the reason or complete the task" do
        login_as provider

        request

        expect(page).to have_error_message("Enter why the Section 8 matter is opposed")
        expect(legal_aid_application.matter_opposition).to be_nil
        expect(matter_opposed_task.state).to eq(:not_started)
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  def matter_opposed_task
    application_tasks = merits_task_list.reload.task_list.tasks[:application]
    application_tasks.detect { |task| task.name == :why_matter_opposed }
  end
end
