module Providers
  class CheckProviderAnswersController < BaseController
    include ApplicationDependable
    include Flowable

    def index
      @proceeding_types = legal_aid_application.proceeding_types
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      legal_aid_application.check_your_answers! unless legal_aid_application.checking_answers?
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def continue
      legal_aid_application.answers_checked!
      go_forward
    end
  end
end
