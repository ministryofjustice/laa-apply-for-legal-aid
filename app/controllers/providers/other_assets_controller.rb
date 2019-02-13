module Providers
  class OtherAssetsController < ProviderBaseController
    def show
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration
    end

    def other_asset_params
      params[:other_assets_declaration].permit(*(Citizens::OtherAssetsForm::ALL_ATTRIBUTES + Citizens::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES))
    end

    def form_params
      other_asset_params.merge(model: declaration)
    end
  end
end
