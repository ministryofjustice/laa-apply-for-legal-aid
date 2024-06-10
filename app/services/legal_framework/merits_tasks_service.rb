module LegalFramework
  class MeritsTasksService
    attr_reader :legal_aid_application

    FULL_SECTION_8_TASKS = %i[
      specific_issue
      prohibited_steps
      nature_of_urgency
      opponents_application
      vary_order
      why_matter_opposed
    ].freeze

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      @response = merits_tasks(submission)

      smtl = SerializableMeritsTaskList.new(@response)
      ignore_questions(smtl)
      update_merits_task_list(smtl.to_yaml)
      smtl
    rescue SubmissionError => e
      submission.error_message = e.message
      submission.save!
      AlertManager.capture_exception(e)
      false
    end

  private

    def update_merits_task_list(serialized_data)
      if MeritsTaskList.exists?(legal_aid_application_id: legal_aid_application.id)
        merits_task_list.update!(serialized_data:, updated_at: Time.current)
      else
        MeritsTaskList.create!(legal_aid_application_id: legal_aid_application.id, serialized_data:)
      end
    end

    def merits_tasks(submission)
      @merits_tasks ||= MeritsTasksRetrieverService.call(submission)
    end

    def merits_task_list
      MeritsTaskList.where(legal_aid_application_id: legal_aid_application.id).first
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id: @legal_aid_application.id)
    end

    def ignore_questions(smtl)
      # loop through and mark any questions that cannot be found
      # as ignored - they can then be hidden in the view
      smtl.tasks[:application].each do |task|
        task.mark_as_ignored! if ignore_task?(task.name)
      end
      smtl.tasks[:proceedings].each_value do |values|
        values[:tasks].each do |task|
          task.mark_as_ignored! if ignore_task?("#{task.name}_html")
        end
      end
      smtl
    end

    def ignore_task?(task_name)
      I18n.t(task_name, scope: "providers.merits_task_lists.show").match(/^translation missing/i).present?
    rescue I18n::MissingTranslationData
      true
    end
  end
end
