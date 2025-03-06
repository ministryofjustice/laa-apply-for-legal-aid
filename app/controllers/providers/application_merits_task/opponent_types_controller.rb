module Providers
  module ApplicationMeritsTask
    class OpponentTypesController < ProviderBaseController
      def show
        form
      end

      def update
        return continue_or_draft if draft_selected?
        return go_forward(form.is_individual?) if form.valid?

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :is_individual,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:is_individual])
      end
    end
  end
end
