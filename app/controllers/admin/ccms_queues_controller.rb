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
      result = submission.complete_restart! # return from service
      status = result ? :notice : :error
      core = "submission #{submission_id}"
      message = status.eql?(:error) ? "Restarting #{core} failed" : "Reset and restarted #{core}"
      flash[status] = message
      redirect_to action: :show
    end

    def restart_current_submission
      result = submission.restart_existing_submission!
      status = result ? :notice : :error
      core = "submission #{submission_id}"
      message = status.eql?(:error) ? "Restarting #{core} failed" : "Restarted #{core}"
      flash[status] = message
      redirect_to action: :show
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
  end
end
