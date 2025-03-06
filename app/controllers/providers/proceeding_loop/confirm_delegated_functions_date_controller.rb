module Providers
  module ProceedingLoop
    class ConfirmDelegatedFunctionsDateController < ProviderBaseController
      before_action :proceeding, :form
      def show; end

      def update
        return continue_or_draft if draft_selected?
        return go_forward(form.confirm_delegated_functions_date?) if form.valid?

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :confirm_delegated_functions_date,
          form_params:,
        )
      end

      def proceeding
        @proceeding = Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:confirm_delegated_functions_date])
      end
    end
  end
end
