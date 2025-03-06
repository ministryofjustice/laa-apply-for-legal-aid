module Providers
  module ApplicationMeritsTask
    class RemoveOpponentController < ProviderBaseController
      def show
        opponent
        form
      end

      def update
        opponent

        if form.valid?
          opponent&.destroy! if form.remove_opponent?
          return go_forward
        end

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_opponent,
          form_params:,
          error: error_message,
        )
      end

      def opponent
        @opponent ||= legal_aid_application.opponents.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:remove_opponent])
      end

      def error_message
        I18n.t("providers.application_merits_task.remove_opponent.show.error", name: @opponent.full_name)
      end
    end
  end
end
