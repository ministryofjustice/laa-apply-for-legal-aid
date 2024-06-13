module Providers
  module ProceedingsSCA
    class SupervisionOrdersController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        form
      end

      def update
        return continue_or_draft if draft_selected?

        if form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "supervision") if form.change_supervision_order?

          return go_forward
        end
        render :show, status: :unprocessable_content
      end

    private

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:change_supervision_order)
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :change_supervision_order,
          form_params:,
          error: error_message,
        )
      end

      def error_message
        I18n.t("providers.proceedings_sca.supervision_orders.error")
      end
    end
  end
end
