module LegalFramework
  class MeritsTasksService
    attr_reader :legal_aid_application

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      @response = merits_tasks(submission)

      smtl = SerializableMeritsTaskList.new(@response)
      update_merits_task_list(smtl.to_yaml)
      smtl
    rescue SubmissionError => e
      submission.error_message = e.message
      submission.save!
      Sentry.capture_exception(e)
      false
    end

    private

    def update_merits_task_list(serialized_data)
      if MeritsTaskList.exists?(legal_aid_application_id: legal_aid_application.id)
        merits_task_list.update!(serialized_data: serialized_data, updated_at: Time.current)
      else
        MeritsTaskList.create!(legal_aid_application_id: legal_aid_application.id, serialized_data: serialized_data)
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
  end
end
