module Providers
  module ProceedingsSCA
    class HeardTogethersController < ProviderBaseController
      prefix_step_with :proceedings_sca
      before_action :current_proceeding

      def show
        @core_proceedings = legal_aid_application.proceedings.where(sca_type: "core")
        amount
        form
      end

      def update
        return continue_or_draft if draft_selected?

        @core_proceedings = legal_aid_application.proceedings.where(sca_type: "core")
        amount

        if form.valid?
          return go_forward({ heard_together: form.heard_together?, proceeding: @current_proceeding })
        end

        render :show, status: :unprocessable_content
      end

    private

      def current_proceeding
        @current_proceeding ||= Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def amount
        @amount = if @core_proceedings.count == 1
                    "single"
                  elsif @core_proceedings.count >= 1
                    "multiple"
                  end
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :heard_together,
          form_params:,
          error: error_message,
        )
      end

      def error_message
        I18n.t("providers.proceedings_sca.heard_togethers.error")
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:heard_together)
      end
    end
  end
end
