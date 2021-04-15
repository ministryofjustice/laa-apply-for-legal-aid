module Providers
  class MeritsTaskListsController < ProviderBaseController
    def show
      @merits_tasks = merits_tasks
    end

    private

    def merits_tasks
      task_list_record = @legal_aid_application.legal_framework_merits_task_list
      if task_list_record.nil?
        LegalFramework::MeritsTasksService.call(@legal_aid_application).tasks
      else
        task_list_record.task_list.tasks
      end
    end
  end
end
