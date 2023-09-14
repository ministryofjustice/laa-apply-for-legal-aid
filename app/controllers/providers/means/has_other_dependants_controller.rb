module Providers
  module Means
    class HasOtherDependantsController < ProviderBaseController
      def show
        form
      end

      def update
        return continue_or_draft if draft_selected?
        return go_forward(form.has_other_dependant?) if form.valid?

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :has_other_dependant,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:has_other_dependant)
      end
    end
  end
end
