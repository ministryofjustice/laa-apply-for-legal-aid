module Citizens
  class OtherAssetsController < BaseController
    def show
      declaration
      @form = Citizens::OtherAssetsForm.new(current_params)
    end

    def update
      @form = Citizens::OtherAssetsForm.new(form_params.merge(model: declaration))
      if @form.save
        render plain: 'Navigate to next question after any other assets'
      else
        render :show
      end
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration
    end

    def attributes
      @attributes ||= Citizens::OtherAssetsForm::ALL_ATTRIBUTES
    end

    def current_params
      @declaration.attributes.symbolize_keys.slice(*attributes)
    end

    def other_asset_params
      params[:other_assets_declaration].permit(*(Citizens::OtherAssetsForm::ALL_ATTRIBUTES + Citizens::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES))
    end

    def form_params
      other_asset_params.merge(model: @declaration)
    end
  end
end
