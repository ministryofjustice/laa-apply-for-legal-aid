module Providers
  module ApplicationMeritsTask
    class OpponentTypesController < ProviderBaseController
      def show
        form
      end

      def update

        render :show
      end

    private
      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :opponent_type,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:opponent_type)
      end
    end
  end
end
