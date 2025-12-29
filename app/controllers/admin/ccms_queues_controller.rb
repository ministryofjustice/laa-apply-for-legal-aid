module Admin
  class CCMSQueuesController < AdminBaseController
    def index
      @in_progress = CCMS::Submission.where.not(aasm_state: %w[completed abandoned lead_application_pending]).order(created_at: :desc)
      @pending = CCMS::Submission.where(aasm_state: :lead_application_pending).order(created_at: :desc).map(&:legal_aid_application)
      @paused = BaseStateMachine.where(aasm_state: %w[submission_paused]).order(:created_at).map(&:legal_aid_application)
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
