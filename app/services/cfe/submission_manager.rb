module CFE
  class SubmissionManager
    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      assessment = CFE::Submission.create!(legal_aid_application_id: @legal_aid_application_id)

      begin
        CFE::CreateAssessmentService.call(assessment)
        CFE::CreateApplicantService.call(assessment)

        # TODO: add these steps as we write the services
        # CFE::CreateCapitalsService.call(assessment)
        # CFE::CreateVehiclesService.call(assessment)
        # CFE::CreatePropertiesService.call(assessment)
        # CFE::ObtainAssessmentResultService.call(assessment)

      rescue CFE::SubmissionError => e
        assessment.error_message = e.message
        assessment.fail!
      end
    end
  end
end
