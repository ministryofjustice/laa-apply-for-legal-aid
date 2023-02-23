module Providers
  module ApplicationMeritsTask
    class RemoveOpponentController < ProviderBaseController
      def show
        form
        opponent
      end

      def update
        if form.valid?
          opponent&.destroy! if form.remove_opponent?
          return go_forward
        end

        opponent
        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_opponent,
          form_params:,
        )
      end

      def opponent
        @opponent ||= legal_aid_application.opponents.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:remove_opponent)
      end
    end
  end
end
