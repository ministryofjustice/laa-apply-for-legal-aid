module Providers
  module ProceedingsSCA
    class HeardAsAlternativesController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        # TODO: Will be updated in ticket AP-5062 which will implement proper flow logic
        @current_proceeding = legal_aid_application.proceedings.last
        @core_proceedings = legal_aid_application.proceedings - [@current_proceeding]
        amount
        form
      end

      def update
        return continue_or_draft if draft_selected?

        # TODO: Will be updated in ticket AP-5062 which will implement proper flow logic
        @current_proceeding = legal_aid_application.proceedings.last
        @core_proceedings = legal_aid_application.proceedings - [@current_proceeding]
        amount

        if form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "heard_as_alternatives") unless form.heard_as_alternative?

          return go_forward
        end
        render :show, status: :unprocessable_content
      end

    private

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
          radio_buttons_input_name: :heard_as_alternative,
          form_params:,
          error: error_message,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:heard_as_alternative)
      end

      def error_message
        I18n.t("providers.proceedings_sca.heard_as_alternatives.show.error")
      end
    end
  end
end
