module Citizens
  class CheckAnswersController < CitizenBaseController
    before_action :authenticate_applicant!

    def index
      legal_aid_application.check_citizen_answers! unless legal_aid_application.checking_citizen_answers?
    end

    def continue
      go_forward
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end
  end
end
