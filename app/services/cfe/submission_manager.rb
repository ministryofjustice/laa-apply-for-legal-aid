module CFE
  class SubmissionManager
    COMMON_SERVICES = [
      CreateAssessmentService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService
    ].freeze

    NON_PASSPORTED_SERVICES = [
      CreateDependantsService,
      CreateStateBenefitsService,
      CreateOtherIncomeService
    ].freeze

    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    attr_reader :legal_aid_application_id
    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      COMMON_SERVICES.each { |s| s.call(submission) }
      NON_PASSPORTED_SERVICES.each { |s| s.call(submission) } if submission.non_passported?
      ObtainAssessmentResultService.call(submission)
      true
    rescue SubmissionError => e
      submission.error_message = e.message
      submission.fail!
      Raven.capture_exception(e)
      false
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id: legal_aid_application_id)
    end
  end
end
