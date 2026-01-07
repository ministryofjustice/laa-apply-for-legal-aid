module Providers
  class MeritsTaskListsController < ProviderBaseController
    before_action :merits_tasks

    def show; end

    def update
      return continue_or_draft if draft_selected? || @legal_aid_application.legal_framework_merits_task_list.can_proceed?

      @merits_task_list.errors.add(:task_list, :incomplete)
      render :show
    end

    def back_button
      # Don't show back link if the user comes from the confirm_non_means_tested_application page,
      # as clicking on it would generate state transition error.
      if URI(back_path).path.eql?(URI(providers_legal_aid_application_confirm_non_means_tested_applications_url).path)
        :none
      else
        { path: back_path }
      end
    end
    helper_method :back_button

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
