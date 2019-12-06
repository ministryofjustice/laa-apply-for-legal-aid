module Providers
  class OwnHomesController < ProviderBaseController
    def show
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      merge_with_model(legal_aid_application, journey: :providers) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:own_home)
      end
    end
  end
end
