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
      result = submission.send(method)
      status = result ? :notice : :error
      message = status.eql?(:error) ? "Restarting submission #{submission_id} failed" : "#{method.to_s.humanize} submission #{submission_id}"
      flash[status] = message
      redirect_to action: :show
    end
  end
end
