module Providers
  module LinkApplication
    class CopiesController < ProviderBaseController
      prefix_step_with :link_application

      before_action :lead_application_reference

      def show
        @form = Providers::LinkApplication::CopyForm.new(model: legal_aid_application)
      end

      def update
        @form = Providers::LinkApplication::CopyForm.new(form_params)

        if draft_selected?
          @form.save_as_draft
          legal_aid_application.update!(draft: draft_selected?)
          return redirect_to draft_target_endpoint
        end

        if @form.valid?
          @form.save!
          flash[:hash] = success_hash if copy_case?
          return go_forward
        end

        render :show
      end

    private

      def success_hash
        {
          title_text: t("generic.success"),
          success: true,
          heading_text: t("providers.link_application.copies.show.success", lead_application_reference:),
        }
      end

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:copy_case)
        end
      end

      def lead_application_reference
        @lead_application ||= @legal_aid_application.lead_application
        @lead_application_reference ||= @lead_application.application_ref
      end

      def copy_case?
        ActiveRecord::Type::Boolean.new.cast(@form.copy_case)
      end
    end
  end
end
