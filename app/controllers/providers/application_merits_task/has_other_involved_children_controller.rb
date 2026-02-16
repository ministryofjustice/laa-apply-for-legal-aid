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

      def destroy
        involved_child.destroy!
        flash[:moj_success] = I18n.t("providers.has_other_involved_children.show.removed", name: involved_child.full_name)
        if involved_children.empty?
          reset_tasks
          replace_last_page_in_history(providers_legal_aid_application_merits_task_list_path)
          return redirect_to new_providers_legal_aid_application_involved_child_path(legal_aid_application)
        end

        @form = LegalAidApplications::HasOtherOpponentsForm.new(model: legal_aid_application)
        render :show
      end

    private

      def involved_children
        legal_aid_application.involved_children
      end

      def involved_child
        @involved_child ||= involved_children&.find(form_params[:involved_child_id])
      end

      def task_list_should_update?
        application_has_task_list? && form.valid? && !draft_selected? && !form.has_other_involved_child?
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :has_other_involved_child,
          form_params:,
        )
      end

      def reset_tasks
        legal_aid_application.legal_framework_merits_task_list.mark_as_not_started!(:application, :children_application)
        legal_aid_application.proceedings.each do |proceeding|
          proceeding_code = proceeding.ccms_code.upcase.to_sym
          next unless legal_aid_application.legal_framework_merits_task_list.includes_task?(proceeding_code, :children_proceeding)

          legal_aid_application.legal_framework_merits_task_list.mark_as_blocked!(proceeding_code, :children_proceeding, :children_application)
        end
      end

      def form_params
        params[:action] == "destroy" ? destroy_form_params : update_form_params
      end

      def destroy_form_params
        params.permit(:involved_child_id)
      end

      def update_form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:has_other_involved_child])
      end
    end
  end
end
