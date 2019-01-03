module Citizens
  class CheckAnswersController < ApplicationController
    include Flowable
    before_action :authenticate_applicant!

    def index
      # TODO: AP-258
      # set legal_aid_application to 'applicant_check_answers' state

      legal_aid_application
    end

    def continue
      legal_aid_application.complete_means! unless legal_aid_application.means_completed?
      go_forward
    end

    # TODO: AP-258
    # def reset
    # end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
