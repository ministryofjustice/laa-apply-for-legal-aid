module Admin
  class CCMSQueuesController < AdminBaseController
    before_action :authenticate_admin_user!

    def index
      @in_progress = CCMS::Submission.where.not(aasm_state: %w[completed abandoned]).order(created_at: :desc)
    end

    def show
      submission
      legal_aid_application
    end

    def reset_and_restart
      execute_submission_method(:restart_from_beginning!)
    end

    def restart_current_submission
      execute_submission_method(:restart_current_step!)
    end

  private

    def submission
      @submission ||= CCMS::Submission.find(submission_id)
    end

    def legal_aid_application
      @legal_aid_application ||= submission.legal_aid_application
    end

    def submission_id
      params.require(:id)
    end

    def execute_submission_method(method)
      submission.public_send(method)
      redirect_to admin_ccms_queue_path(submission.id), notice: "#{method.to_s.humanize.sub('!', '')} submission #{submission_id}"
    end
  end
end
