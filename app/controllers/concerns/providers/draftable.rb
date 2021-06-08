module Providers
  # Adds facility to handle save as draft operations.
  # Note that it requires both `legal_aid_application` and `go_forward`
  # So usually depends on `Flowable` and `ApplicationDependable` being included
  # into the host controller
  module Draftable
    ENDPOINT = Flow::KeyPoint.path_for(journey: :providers, key_point: :home).freeze

    def update_task_save_continue_or_draft(level, task)
      update_task(level, task)
      save_continue_or_draft(@form)
    end

    def update_task(level, task)
      legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(level, task) if task_list_should_update?
    end

    def task_list_should_update?
      application_has_task_list? && !draft_selected? && @form.valid?
    end

    def application_has_task_list?
      legal_aid_application.legal_framework_merits_task_list.present?
    end

    def draft_target_endpoint
      ENDPOINT
    end

    def save_continue_or_draft(form)
      draft_selected? ? form.save_as_draft : form.save
      return false if form.invalid?

      continue_or_draft
    end

    def continue_or_draft
      legal_aid_application.update!(draft: draft_selected?)

      if legal_aid_application.draft?
        redirect_to draft_target_endpoint
      else
        go_forward
      end
    end

    def draft_selected?
      params.key?(:draft_button)
    end
  end
end
