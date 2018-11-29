module Providers
  class CheckProviderAnswersController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def index
      @proceeding = legal_aid_application.proceeding_types.first
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      legal_aid_application.check_your_answers! unless legal_aid_application.checking_answers?
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_step_url
    end
  end
end
