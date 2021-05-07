module Providers
  module ApplicationMeritsTask
    class HasOtherInvolvedChildrenController < ProviderBaseController
      def show
        form
      end

      def update
        # TODO: Remove SafeNavigators after MultiProceeding Feature flag is turned on
        # Until then, some applications will not have a legal_framework_merits_task_list
        # Afterwards - everything should have one!
        legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(:application, :children_application)
        return go_forward(form.has_other_involved_child?) if form.valid?

        render :show
      end

      private

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
