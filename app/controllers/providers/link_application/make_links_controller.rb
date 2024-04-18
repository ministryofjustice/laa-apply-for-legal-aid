module Providers
  module LinkApplication
    class MakeLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        @form = Providers::LinkApplication::MakeLinkForm.new(model: linked_application)
      end

      def update
        @form = Providers::LinkApplication::MakeLinkForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(linked_application) do
          next {} unless params[:linked_application]

          params.require(:linked_application).permit(:link_type_code)
        end
      end

      def linked_application
        legal_aid_application.lead_linked_application || legal_aid_application.build_lead_linked_application
      end
    end
  end
end
