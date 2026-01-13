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
      expect(page).to have_title("Incomplete CCMS Submissions")
    end

    context "when there are no applications on the queue" do
      it "displays a count in header" do
        get_index
        expect(page).to have_css("h2", text: "Processing queue (0)")
      end

      it "displays a warning message" do
        get_index
        expect(page).to have_content("The sidekiq queue is empty")
      end
    end

    context "when an application is on the queue" do
      let!(:ccms_submission) do
        create(:ccms_submission, :case_ref_obtained).tap do |submission|
          submission.legal_aid_application.update!(merits_submitted_at: 1.hour.ago)
        end
      end

      it "displays a count in header" do
        get_index
        expect(page).to have_css("h2", text: "Processing queue (1)")
      end

      it "has a link to the application" do
        get_index
        expect(page).to have_link(href: admin_ccms_queue_path(ccms_submission.id))
      end

      it "displays the date submission was created" do
        freeze_time do
          get_index
          expect(page).to have_content(ccms_submission.legal_aid_application.ccms_submission.created_at.strftime("%-d %B %Y @ %l:%M%p").squish)
        end
      end
    end

    context "when there are no paused applications" do
      it "displays a count in header" do
        get_index
        expect(page).to have_css("h2", text: "Paused submissions (0)")
      end

      it "displays a warning message" do
        get_index
        expect(page).to have_content("There are no paused submissions")
      end
    end

    context "when there is a paused application" do
      let!(:legal_aid_application) { create(:legal_aid_application, :submission_paused, merits_submitted_at: 1.hour.ago) }

      it "displays a count in header" do
        get_index
        expect(page).to have_css("h2", text: "Paused submissions (1)")
      end

      it "has a link to the application" do
        get_index
        expect(page).to have_link(href: admin_legal_aid_applications_submission_path(legal_aid_application))
      end

      it "displays the date application was submitted" do
        freeze_time do
          get_index
          expect(page).to have_content(legal_aid_application.merits_submitted_at.strftime("%-d %B %Y @ %l:%M%p").squish)
        end
      end
    end

    context "when there is a linked application in lead_application_pending state" do
      let!(:legal_aid_application) { create(:legal_aid_application, :submitting_assessment, merits_submitted_at: 1.hour.ago) }
      let(:lead_application) { create(:legal_aid_application) }

      before do
        create(:linked_application, lead_application:, associated_application: legal_aid_application, link_type_code: "FC_LEAD")
        create(:ccms_submission, :initialised, legal_aid_application: lead_application)
        create(:ccms_submission, :lead_application_pending, legal_aid_application:)
      end

      it "displays a count in header" do
        get_index
        expect(page).to have_css("h2", text: "Pending lead submissions (1)")
      end

      it "has a link to the application" do
        get_index
        expect(page).to have_link(href: admin_ccms_queue_path(legal_aid_application.ccms_submission))
      end

      it "displays the date application was submitted" do
        freeze_time do
          get_index
          expect(page).to have_content(legal_aid_application.merits_submitted_at.strftime("%-d %B %Y @ %l:%M%p").squish)
        end
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
      expect(page).to have_content(ccms_submission.case_ccms_reference)
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
