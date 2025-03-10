module Providers
  module ProceedingMeritsTask
    class LinkedChildrenController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::LinkedChildrenForm.new(model: proceeding)
      end

      def update
        @form = Providers::ProceedingMeritsTask::LinkedChildrenForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :children_proceeding)
      end

    private

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def proceeding
        @proceeding ||= Proceeding.find(merits_task_list_id)
      end

      def merits_task_list_id
        params["merits_task_list_id"]
      end

      def form_params
        merge_with_model(proceeding) do
          params.expect(proceeding_merits_task_proceeding_linked_child: [linked_children: []])
        end
      end
    end
  end
end
