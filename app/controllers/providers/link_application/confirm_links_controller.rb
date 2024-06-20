module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: linked_application)
      end

      def update
        @form = Providers::LinkApplication::ConfirmLinkForm.new(form_params)

        if draft_selected?
          @form.save_as_draft
          legal_aid_application.update!(draft: draft_selected?)
          return redirect_to draft_target_endpoint
        end

        if @form.valid?
          @form.save!
          flash[:hash] = success_hash if @form.confirm_link == "true"
          return go_forward
        end

        render :show
      end

    private

      def success_hash
        {
          title_text: t("generic.success"),
          success: true,
          heading_text:,
        }
      end

      def heading_text
        @heading_text ||= legal_aid_application.lead_linked_application&.link_type_code == "FC_LEAD" ? t("providers.link_application.confirm_links.show.success_family") : t("providers.link_application.confirm_links.show.success_legal", application_ref: legal_aid_application.lead_application&.application_ref)
      end

      def linked_application
        legal_aid_application.lead_linked_application
      end

      def form_params
        merge_with_model(linked_application) do
          next {} unless params[:linked_application]

          params.require(:linked_application).permit(:confirm_link)
        end
      end
    end
  end
end
