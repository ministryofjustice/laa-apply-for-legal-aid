module Providers
  class CheckProviderAnswersController < ProviderBaseController
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
      update_applicant_age_for_means_test_purposes!

      continue_or_draft
    end

  private

    def update_applicant_age_for_means_test_purposes!
      legal_aid_application
        .applicant
        .update!(age_for_means_test_purposes: current_age_for_means_test_purposes)
    end

    def current_age_for_means_test_purposes
      date_of_birth = legal_aid_application.applicant.date_of_birth
      as_of = legal_aid_application.used_delegated_functions_on || Date.current

      AgeCalculator.call(date_of_birth, as_of)
    end

    def set_variables
      @applicant = legal_aid_application.applicant
      @partner = legal_aid_application.partner
      @read_only = legal_aid_application.read_only?
      @address = @applicant.address
      @show_linked_proceedings = @legal_aid_application.copy_case? && @legal_aid_application.proceedings.count.zero?
      @source_application = @show_linked_proceedings ? LegalAidApplication.find(legal_aid_application.copy_case_id) : legal_aid_application
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
