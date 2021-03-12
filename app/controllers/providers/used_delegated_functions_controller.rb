module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(form_params)

      render :show unless save_continue_or_draft_and_update_scope_limitations
    end

    private

    def save_continue_or_draft_and_update_scope_limitations
      return false unless save_continue_or_draft(@form)

      remove_delegated_scope_limitations unless @form.model.used_delegated_functions?
      update_scope_limitations
      true
    end

    def update_scope_limitations
      return unless @form.model.used_delegated_functions?

      AddScopeLimitationService.call(legal_aid_application, :delegated)  # To be removed in ap-2047
      add_delegated_scope_limitations

      submit_application_reminder if @form.model&.used_delegated_functions_on && @form.model.used_delegated_functions_on >= 1.month.ago
    end

    def submit_application_reminder
      return if legal_aid_application.awaiting_applicant?
      return if legal_aid_application.applicant_entering_means?

      SubmitApplicationReminderService.new(legal_aid_application).send_email
    end

    def application_proceeding_types
      @legal_aid_application.application_proceeding_types
    end

    def remove_delegated_scope_limitations
      application_proceeding_types.each(&:remove_default_delegated_functions_scope_limitation)
    end

    def add_delegated_scope_limitations
      application_proceeding_types.each do |application_proceeding_type|
        AddAssignedScopeLimitationService.call(@legal_aid_application, application_proceeding_type.proceeding_type_id, :delegated)
      end
    end

    def form_params
      merged_params = merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(
          :used_delegated_functions_on,
          :used_delegated_functions
        )
      end
      convert_date_params(merged_params)
    end
  end
end
