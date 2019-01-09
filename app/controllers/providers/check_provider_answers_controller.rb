module Providers
  class CheckProviderAnswersController < BaseController
    include ApplicationDependable
    include SaveAsDraftable
    include Steppable

    def index
      @proceeding = legal_aid_application.proceeding_types.first
      @applicant = legal_aid_application.applicant
      @address = @applicant.addresses.first
      @back_step_url = back_step_path
      legal_aid_application.check_your_answers! unless legal_aid_application.checking_answers?
    end

    def reset
      legal_aid_application.reset!
      redirect_to reset_redirect_path
    end

    def continue
      legal_aid_application.answers_checked!
      continue_or_save_draft
    end

    private

    def reset_redirect_path
      return providers_legal_aid_application_address_selection_path if applicant.address&.lookup_used?

      providers_legal_aid_application_address_path
    end

    def back_step_path
      # return providers_legal_aid_application_address_selection_path if applicant.address&.lookup_used?
      #
      # providers_legal_aid_application_address_path
      if legal_aid_application.own_capital?
        providers_legal_aid_application_restrictions_path(legal_aid_application)
      else
        providers_legal_aid_application_other_assets_path(legal_aid_application)
      end
    end
  end
end
