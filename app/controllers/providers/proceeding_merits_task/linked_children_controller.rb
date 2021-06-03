module Providers
  module ProceedingMeritsTask
    class LinkedChildrenController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::LinkedChildrenForm.new(model: application_proceeding_type)
      end

      def update
        @form = Providers::ProceedingMeritsTask::LinkedChildrenForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(proceeding_type.ccms_code.to_sym, :children_proceeding)
      end

      private

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def proceeding_type
        @proceeding_type ||= application_proceeding_type.proceeding_type
      end

      def application_proceeding_type
        @application_proceeding_type ||= ApplicationProceedingType.find(merits_task_list_id)
      end

      def merits_task_list_id
        params['merits_task_list_id']
      end

      def form_params
        merge_with_model(application_proceeding_type) do
          params.require(:proceeding_merits_task_application_proceeding_type_linked_child).permit(linked_children: [])
        end
      end
    end
  end
end
