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
      submission = CFE::Submission.create!(legal_aid_application_id: @legal_aid_application_id)

      begin
        CFE::CreateAssessmentService.call(submission)
        CFE::CreateApplicantService.call(submission)
        CFE::CreateCapitalsService.call(submission)
        CFE::CreateVehiclesService.call(submission)
        CFE::ObtainAssessmentResultService.call(submission)
      rescue CFE::SubmissionError => e
        assessment.error_message = e.message
        assessment.fail!
      end
    end
  end
end
