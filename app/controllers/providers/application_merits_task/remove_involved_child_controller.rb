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
          reset_tasks unless legal_aid_application.involved_children.any?
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

      def reset_tasks
        legal_aid_application.legal_framework_merits_task_list.mark_as_not_started!(:application, :children_application)
        legal_aid_application.proceedings.each do |proceeding|
          proceeding_code = proceeding.ccms_code.upcase.to_sym
          next unless legal_aid_application.legal_framework_merits_task_list.includes_task?(proceeding_code, :children_proceeding)

          legal_aid_application.legal_framework_merits_task_list.mark_as_blocked!(proceeding_code, :children_proceeding, :children_application)
        end
      end
    end
  end
end
