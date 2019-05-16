module Providers
  class OtherAssetsController < ProviderBaseController
    def show
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(model: declaration)
    end

    def update
      authorize @legal_aid_application
      @form = Citizens::OtherAssetsForm.new(form_params)
      @form.errors.add :base, :provider_none_selected unless draft_selected? || none_checkbox_selected? || @form.any_checkbox_checked?
      render :show unless !@form.errors.present? && save_continue_or_draft(@form)
    end

    private

    def declaration
      @declaration ||= legal_aid_application.other_assets_declaration || legal_aid_application.create_other_assets_declaration!
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
