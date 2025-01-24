require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::IsMatterOpposedController do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_proceedings,
      explicit_proceedings: %i[pbm40],
    )
  end

  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/is_matter_opposed" do
    subject(:request) do
      get providers_legal_aid_application_is_matter_opposed_path(legal_aid_application)
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
          matter_opposed: true,
        )
        login_as provider

        request

        expect(page).to have_field(
          "application_merits_task_matter_opposition[matter_opposed]",
          with: "true",
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

  describe "PATCH /providers/applications/:legal_aid_application_id/is_matter_opposed" do
    subject(:request) do
      patch providers_legal_aid_application_is_matter_opposed_path(legal_aid_application),
            params: params.merge(button_clicked)
    end

    let(:merits_task_list) do
      create(
        :legal_framework_merits_task_list,
        :pbm40_as_applicant,
        legal_aid_application:,
      )
    end

    let(:params) { { application_merits_task_matter_opposition: { matter_opposed: } } }
    let(:matter_opposed) { true }
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

      it "updates the matter_opposed, completes the task, and redirects to the next page" do
        login_as provider

        request

        expect(legal_aid_application.matter_opposition.matter_opposed).to eq(matter_opposed)
        expect(matter_opposed_task.state).to eq(:complete)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider saves as draft" do
      let(:button_clicked) { draft_button }

      it "updates the matter_opposed, does not complete the task, and redirects to the applications page" do
        login_as provider

        request

        expect(legal_aid_application.matter_opposition.matter_opposed).to eq(matter_opposed)
        expect(matter_opposed_task.state).to eq(:not_started)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the application has a matter_opposed" do
      let(:matter_opposed) { false }

      it "updates the reason" do
        matter_opposition = create(
          :matter_opposition,
          legal_aid_application:,
          reason: true,
        )
        login_as provider

        request

        expect(ApplicationMeritsTask::MatterOpposition.count).to eq(1)
        expect(matter_opposition.reload.matter_opposed).to eq(matter_opposed)
      end
    end

    context "when the form is invalid" do
      let(:matter_opposed) { nil }

      it "displays an error and does not update the reason or complete the task" do
        login_as provider

        request

        expect(page).to have_error_message("Select yes if the matter is opposed by your client")
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
    application_tasks.detect { |task| task.name == :matter_opposed }
  end
end
