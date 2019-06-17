module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
    def show
      authorize legal_aid_application
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(model: legal_aid_application)
    end

    def update
      authorize legal_aid_application
      @form = LegalAidApplications::UsedDelegatedFunctionsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

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
