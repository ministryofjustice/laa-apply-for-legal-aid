module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: legal_aid_application)
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
          flash[:hash] = success_hash if @form.link_case == "true"
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

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:link_case)
        end
      end
    end
  end
end
