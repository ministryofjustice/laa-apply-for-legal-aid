module Providers
  class SubstantiveApplicationsController < ProviderBaseController
    def show
      authorize legal_aid_application
      @form = LegalAidApplications::SubstantiveApplicationForm.new(model: legal_aid_application)
    end

    def update
      authorize legal_aid_application
      @form = LegalAidApplications::SubstantiveApplicationForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
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
