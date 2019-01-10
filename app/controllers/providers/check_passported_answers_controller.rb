module Providers
  class CheckPassportedAnswersController < BaseController
    include ApplicationDependable
    include SaveAsDraftable
    include Steppable

    def show
      @proceeding = legal_aid_application.proceeding_types.first
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      @back_step_url = back_step_path
      legal_aid_application.check_passported_answers! unless legal_aid_application.checking_passported_answers?
    end

    private

    def back_step_path
      '/home'
    end
  end
end
