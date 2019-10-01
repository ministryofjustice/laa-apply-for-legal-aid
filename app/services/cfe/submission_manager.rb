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

      # TODO: add these steps as we write the services
      # CFE::ObtainAssessmentResultService.call(submission)
    rescue CFE::SubmissionError => e
      submission.error_message = e.message
      submission.fail!
    end

    def submission
      @submission ||= CFE::Submission.create!(legal_aid_application_id: legal_aid_application_id)
    end
  end
end
