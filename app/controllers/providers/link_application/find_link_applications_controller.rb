module Providers
  module LinkApplication
    class FindLinkApplicationsController < ProviderBaseController
      prefix_step_with :link_application

      def show
        @form = Providers::LinkApplication::FindLinkApplicationForm.new(model: linked_application)
      end

      def update
        @form = Providers::LinkApplication::FindLinkApplicationForm.new(form_params)

        if @form.valid?
          search_result = @form.application_can_be_linked?
          return save_continue_or_draft(@form) if search_result == true

          flash[:hash] = send(search_result)
        end

        render :show
      end

    private

      def missing_message
        {
          title_text: t("generic.information"),
          success: false,
          heading_text: "We could not find an application with the LAA reference of #{form_params[:search_laa_reference]}.",
        }
      end

      def not_submitted_message
        {
          title_text: t("generic.information"),
          success: false,
          heading_text: "Submit #{form_params[:search_laa_reference]} if you want to link to it.",
          link_text: "Find this application",
          link_href: search_providers_legal_aid_applications_path(search_term: form_params[:search_laa_reference]),
          text: "Your progress here will be saved, and you can come back to this page later.",
        }
      end

      def linked_application
        legal_aid_application.lead_linked_application || legal_aid_application.build_lead_linked_application
      end

      def form_params
        merge_with_model(linked_application) do
          params.require(:linked_application).permit(:search_laa_reference)
        end
      end
    end
  end
end
