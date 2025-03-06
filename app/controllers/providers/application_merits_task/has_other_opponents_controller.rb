module Providers
  module ApplicationMeritsTask
    class HasOtherOpponentsController < ProviderBaseController
      def show
        form
      end

      def update
        update_task(:application, :opponent_name)
        return continue_or_draft if draft_selected?
        return go_forward(form.has_other_opponents?) if form.valid?

        render :show
      end

    private

      def task_list_should_update?
        application_has_task_list? && form.valid? && !draft_selected? && !form.has_other_opponents?
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :has_other_opponents,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:has_other_opponents])
      end
    end
  end
end
