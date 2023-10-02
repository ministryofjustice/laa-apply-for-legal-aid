module Providers
  module Means
    class OtherAssetsController < ProviderBaseController
      def show
        @form = Providers::OtherAssetsForm.new(model: declaration)
      end

      def update
        @form = Providers::OtherAssetsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def declaration
        @declaration ||= legal_aid_application.other_assets_declaration || legal_aid_application.create_other_assets_declaration!
      end

      def form_params
        merge_with_model(declaration, journey: :providers) do
          attrs = Providers::OtherAssetsForm::ALL_ATTRIBUTES + Providers::OtherAssetsForm::CHECK_BOXES_ATTRIBUTES
          params[:other_assets_declaration].permit(*attrs)
        end
      end
    end
  end
end
