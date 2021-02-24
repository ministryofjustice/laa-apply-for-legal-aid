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

      # clear_delegated_functions_scope_if_it_exists
      RemoveScopeLimitationService.call(@legal_aid_application) unless @form.model.used_delegated_functions?
      AddScopeLimitationService.call(legal_aid_application, :delegated) if @form.model.used_delegated_functions?
      AddAssignedScopeLimitationService.call(@legal_aid_application, :delegated) if @form.model.used_delegated_functions?
      true
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
