module Providers
  class MeritsTaskListsController < ProviderBaseController
    before_action :merits_tasks

    def show; end

    def update
      return continue_or_draft if draft_selected? || @legal_aid_application.legal_framework_merits_task_list.can_proceed?

      @merits_task_list.errors.add(:task_list, :incomplete)
      render :show
    end

  private

    def merits_tasks
      @merits_tasks ||= task_list_record
    end

    def merits_task_list
      @merits_task_list ||= @legal_aid_application.legal_framework_merits_task_list
    end

    def task_list_record
      if merits_task_list.nil?
        LegalFramework::MeritsTasksService.call(@legal_aid_application).tasks
      else
        LegalFramework::OpponentTaskUpdateService.call(@legal_aid_application)
        merits_task_list.task_list.tasks
      end
    end
  end
end
