module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        link_type
        all_linked_applications
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: legal_aid_application)
      end

      def update
        link_type
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
        @all_linked_applications ||= LinkedApplication.where("lead_application_id = ? AND associated_application_id != ? AND link_type_code = ?", legal_aid_application.lead_application&.id, legal_aid_application.id, link_type_code).map(&:associated_application)
      end

      def link_type
        @link_type ||= LinkedApplicationType.all.find { |linked_application_type| linked_application_type.code == link_type_code }
      end

      def link_type_code
        @link_type_code ||= legal_aid_application.lead_linked_application&.link_type_code
      end
    end
  end
end
