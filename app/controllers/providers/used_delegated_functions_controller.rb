module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
    def show
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(form_params)
      if save_continue_or_draft_and_update_scope_limitations
        submit_application_reminder
      else
        render :show
      end
    end

    private

    def submit_application_reminder
      return if legal_aid_application.awaiting_applicant?
      return if legal_aid_application.applicant_entering_means?
      return unless @form.model.used_delegated_functions?

      SubmitApplicationReminderService.new(legal_aid_application).send_email
    end

    def save_continue_or_draft_and_update_scope_limitations
      return false unless save_continue_or_draft(@form)

      legal_aid_application.add_default_delegated_functions_scope_limitation! if @form.model.used_delegated_functions?
      true
    end

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(
          :used_delegated_functions_year,
          :used_delegated_functions_month,
          :used_delegated_functions_day,
          :used_delegated_functions
        )
      end
    end
  end
end
