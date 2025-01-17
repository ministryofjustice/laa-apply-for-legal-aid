require "rails_helper"

RSpec.describe Admin::CCMSQueuesController do
  let(:admin_user) { create(:admin_user) }

  describe "GET index" do
    subject(:get_index) { get admin_ccms_queues_path }

    before do
      sign_in admin_user
    end

    it "renders successfully" do
      get_index
      expect(response).to have_http_status(:ok)
    end

    it "displays page title" do
      get_index
      expect(response.body).to include("Incomplete CCMS Submissions")
    end

    context "when there are no applications on the queue" do
      it "displays a warning message" do
        get_index
        expect(response.body).to include("The sidekiq queue is empty")
      end
    end

    context "when an application is on the queue" do
      let!(:ccms_submission) { create(:ccms_submission, :case_ref_obtained) }

      it "has a link to the application" do
        get_index
        expect(response.body).to include(admin_ccms_queue_path(ccms_submission.id))
      end
    end

    context "when there are no paused applications" do
      it "displays a warning message" do
        get_index
        expect(response.body).to include("There are no paused submissions")
      end
    end

    context "when there is a paused application" do
      let!(:legal_aid_application) { create(:legal_aid_application, :submission_paused) }

      it "has a link to the application" do
        get_index
        expect(response.body).to include(admin_legal_aid_applications_submission_path(legal_aid_application))
      end
    end
  end

  describe "GET show" do
    subject(:get_show) { get admin_ccms_queue_path(ccms_submission.id) }

    let!(:ccms_submission) { create(:ccms_submission, :case_ref_obtained) }

    before do
      sign_in admin_user
      get_show
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays ccms case reference" do
      expect(response.body).to include(ccms_submission.case_ccms_reference)
    end
  end

  describe "GET reset_and_restart" do
    subject(:get_reset_and_restart) { get reset_and_restart_admin_ccms_queue_path(ccms_submission.id) }

    before { sign_in admin_user }

    let!(:ccms_submission) { create(:ccms_submission, :case_ref_obtained) }

    it "calls submission.complete_restart!" do
      expect(get_reset_and_restart).to redirect_to(admin_ccms_queue_path(ccms_submission.id))
    end
  end

  describe "GET restart_current_submission" do
    subject(:get_restart_current_submission) { get restart_current_submission_admin_ccms_queue_path(ccms_submission.id) }

    let!(:ccms_submission) { create(:ccms_submission, :case_ref_obtained) }

    before { sign_in admin_user }

    it "calls submission.restart_current_submission" do
      expect(get_restart_current_submission).to redirect_to(admin_ccms_queue_path(ccms_submission.id))
      expect(flash[:notice]).to match(ccms_submission.id)
    end
  end
end
