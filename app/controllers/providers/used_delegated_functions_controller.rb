module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
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
