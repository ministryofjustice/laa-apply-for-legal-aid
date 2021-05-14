module Providers
  class InScopeOfLasposController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      @form = LegalAidApplications::InScopeOfLaspoForm.new(model: legal_aid_application)
      render :show
    end

    def update
      return continue_or_draft if draft_selected?

      @form = LegalAidApplications::InScopeOfLaspoForm.new(form_params)

      if save_continue_or_draft(@form)
        go_forward
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        params.permit(:in_scope_of_laspo)
      end
    end
  end
end
