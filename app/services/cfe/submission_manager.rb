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
      CreateOutgoingsService,
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

      # move CreateIrregularIncomesService up into the NON_PASSPORTED_SERVICES when removing the use_new_student_loan feature flag
      CreateIrregularIncomesService.call(submission) if submission.non_passported? && Setting.use_new_student_loan?

      ObtainAssessmentResultService.call(submission)
      true
    rescue SubmissionError => e
      submission.error_message = e.message
      Raven.capture_exception(e)
      submission.fail! unless submission.failed?
      false
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id: legal_aid_application_id)
    end
  end
end
