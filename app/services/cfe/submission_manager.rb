module CFE
  class SubmissionManager
    include ::DurationLogger

    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    attr_reader :legal_aid_application_id

    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      make_logged_call_to CreateAssessmentService
      Async do |task|
        services.each do |service|
          task.async { make_logged_call_to service }
        end
      end
      make_logged_call_to ObtainAssessmentResultService
      true
    rescue SubmissionError => e
      submission.error_message = e.message
      AlertManager.capture_exception(e)
      submission.fail! unless submission.failed?
      false
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id:)
    end

  private

    def services
      ServiceSet.call(submission)
    end

    def make_logged_call_to(service)
      log_duration("CFE Submission :: call to #{service} for #{legal_aid_application_id}") do
        service.call(submission)
      end
    end
  end
end
