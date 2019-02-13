module Providers
  class OwnHomesController < ProviderBaseController
    def show
      authorize @legal_aid_application
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      authorize @legal_aid_application
      @form = LegalAidApplications::OwnHomeForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def own_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end
  end
end
