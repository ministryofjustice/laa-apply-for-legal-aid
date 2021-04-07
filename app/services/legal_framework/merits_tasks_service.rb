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
      MeritsTaskList.create!(legal_aid_application_id: legal_aid_application.id, serialized_data: smtl.to_yaml)

      true
    rescue SubmissionError => e
      submission.error_message = e.message
      submission.save!
      Sentry.capture_exception(e)
      false
    end

    private

    def merits_tasks(submission)
      @merits_tasks ||= MeritsTasksRetrieverService.call(submission)
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id: @legal_aid_application.id)
    end
  end
end
