module Providers
  module ApplicationMeritsTask
    class RemoveInvolvedChildController < ProviderBaseController
      def show
        involved_child
        form
      end

      def update
        involved_child

        if form.valid?
          involved_child&.destroy! if form.remove_involved_child?
          return go_forward
        end

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_involved_child,
          form_params:,
          error: error_message,
        )
      end

      def error_message
        I18n.t("providers.application_merits_task.remove_involved_child.show.error", name: @involved_child.full_name)
      end

      def involved_child
        @involved_child ||= legal_aid_application.involved_children.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:remove_involved_child])
      end
    end
  end
end
