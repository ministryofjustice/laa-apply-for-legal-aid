module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: legal_aid_application)
      end

      def update
        @form = Providers::LinkApplication::ConfirmLinkForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:link_case)
        end
      end
    end
  end
end
