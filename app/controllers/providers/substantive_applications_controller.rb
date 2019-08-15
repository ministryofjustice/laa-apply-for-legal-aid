module Providers
  class SubstantiveApplicationsController < ProviderBaseController
    def show
      @form = LegalAidApplications::SubstantiveApplicationForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SubstantiveApplicationForm.new(form_params)
      if save_continue_or_draft(@form)
        legal_aid_application.provider_used_delegated_functions!
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params.key?(:legal_aid_application)

        params.require(:legal_aid_application).permit(:substantive_application)
      end
    end
  end
end
