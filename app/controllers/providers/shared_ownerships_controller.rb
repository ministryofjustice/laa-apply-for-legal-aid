module Providers
  class SharedOwnershipsController < ProviderBaseController
    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def shared_ownership_params
      merge_with_model(legal_aid_application, journey: :providers) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:shared_ownership)
      end
    end
  end
end
