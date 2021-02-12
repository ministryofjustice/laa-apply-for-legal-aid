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

      # AddScopeLimitationService.call(legal_aid_application, :delegated) if @form.model.used_delegated_functions?
      true
    end

    def form_params
      merge_with_model(legal_aid_application) do
        convert_date_params('legal_aid_application')
        params.require(:legal_aid_application).permit(
          :used_delegated_functions_on_1i,
          :used_delegated_functions_on_2i,
          :used_delegated_functions_on_3i,
          :used_delegated_functions
        )
      end
    end
  end
end
