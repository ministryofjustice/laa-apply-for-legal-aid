module Citizens
  class OtherAssetsController < CitizenBaseController
    def show
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      @form = Citizens::OtherAssetsForm.new(form_params)
      return go_forward if @form.save

      render :show
    end

    private

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration || legal_aid_application.build_other_assets_declaration
    end

    def form_params
      merge_with_model(declaration, journey: :citizens) do
        attrs = Citizens::OtherAssetsForm::ALL_ATTRIBUTES + Citizens::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES
        params[:other_assets_declaration].permit(*attrs)
      end
    end
  end
end
