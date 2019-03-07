module Citizens
  class CheckAnswersController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def index
      legal_aid_application.check_citizen_answers! unless legal_aid_application.checking_citizen_answers?
    end

    def continue
      legal_aid_application.complete_means! unless legal_aid_application.means_completed?
      legal_aid_application.update!(provider_step: :merits_start)
      go_forward
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end
  end
end
