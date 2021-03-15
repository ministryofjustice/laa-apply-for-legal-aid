module Providers
  class CheckProviderAnswersController < ProviderBaseController
    include PreDWPCheckVisible

    def index
      return redirect_to_client_completed_means if legal_aid_application.provider_assessing_means?

      set_variables
      legal_aid_application.check_applicant_details! unless status_change_not_required?
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def continue
      continue_or_draft
    end

    private

    def set_variables
      @applicant = legal_aid_application.applicant
      @read_only = legal_aid_application.read_only?
      @address = @applicant.addresses.first
    end

    # This handles the situation where a provider is viewing providers/applications and a citizens completes their
    # journey - causing the link to the application to be out of step with the provider step.
    def redirect_to_client_completed_means
      redirect_to providers_legal_aid_application_client_completed_means_path(legal_aid_application)
    end

    def status_change_not_required?
      legal_aid_application.checking_applicant_details? ||
        legal_aid_application.applicant_entering_means? ||
        legal_aid_application.awaiting_applicant? ||
        legal_aid_application.checking_citizen_answers?
    end
  end
end
