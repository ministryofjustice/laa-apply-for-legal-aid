module Providers
  module ProceedingsSCA
    class HeardAsAlternativesController < ProviderBaseController
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
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "heard_as_alternatives") unless form.heard_as_alternative?

          return go_forward(@current_proceeding)
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
          radio_buttons_input_name: :heard_as_alternative,
          form_params:,
          error: error_message,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:heard_as_alternative])
      end

      def error_message
        I18n.t("providers.proceedings_sca.heard_as_alternatives.show.error")
      end
    end
  end
end
