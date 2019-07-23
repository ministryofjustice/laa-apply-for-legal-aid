module Providers
  class RestrictionsController < ProviderBaseController
    def show
      authorize @legal_aid_application
      @form = LegalAidApplications::RestrictionsForm.new(model: legal_aid_application)
    end

    def update
      authorize @legal_aid_application
      @form = LegalAidApplications::RestrictionsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      merge_with_model(legal_aid_application, mode: :provider) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:has_restrictions, :restrictions_details)
      end
    end
  end
end
