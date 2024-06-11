module Providers
  module ProceedingsSCA
    class ChildSubjectsController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        @proceeding = legal_aid_application.proceedings.last
        form
      end

      def update
        return continue_or_draft if draft_selected?

        @proceeding = legal_aid_application.proceedings.last
        if form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "child_subject") unless form.child_subject?

          return go_forward
        end
        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :child_subject,
          form_params:,
          error: error_message,
        )
      end

      def error_message
        I18n.t("providers.proceedings_sca.child_subjects.error")
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:child_subject)
      end
    end
  end
end
