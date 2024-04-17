module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        all_linked_applications
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: legal_aid_application)
      end

      def update
        all_linked_applications
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

      def all_linked_applications
        @all_linked_applications = legal_aid_application.lead_application&.associated_applications&.where&.not(id: legal_aid_application.id)
      end
    end
  end
end
