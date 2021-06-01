module Providers
  module ApplicationMeritsTask
    class HasOtherInvolvedChildrenController < ProviderBaseController
      def show
        form
      end

      def update
        update_task(:application, :children_application)
        return continue_or_draft if draft_selected?
        return go_forward(form.has_other_involved_child?) if form.valid?

        render :show
      end

      private

      def task_list_should_update?
        application_has_task_list? && form.valid? && !draft_selected? && !form.has_other_involved_child?
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :has_other_involved_child,
          form_params: form_params
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:has_other_involved_child)
      end
    end
  end
end
