module Providers
  class CheckPassportedAnswersController < BaseController
    include ApplicationDependable
    include Flowable

    def show
      @proceeding = legal_aid_application.proceeding_types.first
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      legal_aid_application.check_passported_answers! unless legal_aid_application.checking_passported_answers?
    end

    def continue
      legal_aid_application.complete_means! unless legal_aid_application.means_completed?

      go_forward
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end
  end
end
