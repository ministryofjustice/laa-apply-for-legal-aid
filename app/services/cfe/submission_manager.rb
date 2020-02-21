module CFE
  class SubmissionManager
    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    attr_reader :legal_aid_application_id
    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      CFE::CreateAssessmentService.call(submission)
      CFE::CreateApplicantService.call(submission)
      CFE::CreateCapitalsService.call(submission)
      CFE::CreateVehiclesService.call(submission)
      CFE::CreatePropertiesService.call(submission)
      CFE::ObtainAssessmentResultService.call(submission)
      true
    rescue CFE::SubmissionError => e
      submission.error_message = e.message
      submission.fail!
      Raven.capture_exception(e)
      false
    end

    def submission
      @submission ||= CFE::V1::Submission.create!(legal_aid_application_id: legal_aid_application_id)
    end
  end
end
