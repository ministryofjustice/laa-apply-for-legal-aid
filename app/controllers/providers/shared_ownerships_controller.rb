module Providers
  class SharedOwnershipsController < ProviderBaseController
    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      render :show unless save_continue_or_draft(@form)
    end

    private

    def shared_ownership_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:shared_ownership)
    end
  end
end
