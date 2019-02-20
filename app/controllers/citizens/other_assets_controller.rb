module Citizens
  class OtherAssetsController < BaseController
    include ApplicationFromSession

    def show
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      @form = Citizens::OtherAssetsForm.new(form_params)
      if @form.save
        go_forward
      else
        render :show
      end
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
