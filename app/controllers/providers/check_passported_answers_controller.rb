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

    def continue
      legal_aid_application.complete_means! unless legal_aid_application.means_completed?

      redirect_to next_step_url
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_step_path
    end

    private

    def back_step_path
      legal_aid_application.own_capital? ? restrictions_path : other_assets_path
    end

    def restrictions_path
      providers_legal_aid_application_restrictions_path(legal_aid_application)
    end

    def other_assets_path
      providers_legal_aid_application_other_assets_path(legal_aid_application)
    end
  end
end
