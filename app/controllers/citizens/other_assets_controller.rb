module Citizens
  class OtherAssetsController < BaseController
    include ApplicationFromSession

    def show
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      @form = Citizens::OtherAssetsForm.new(form_params)
      if none_checkbox_selected? || @form.any_checkbox_checked?
        return go_forward if @form.save
      else
        @form.errors.add :base, :citizen_none_selected
      end
      render :show
    end

    private

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration || legal_aid_application.build_other_assets_declaration
    end

    def form_params
      merge_with_model(declaration) do
        attrs = Citizens::OtherAssetsForm::ALL_ATTRIBUTES + Citizens::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES
        params[:other_assets_declaration].permit(*attrs)
      end
    end

    def none_checkbox_selected?
      params[:none_selected] == 'true'
    end
  end
end
