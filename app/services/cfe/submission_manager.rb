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
      call_common_services
      call_non_passported_services
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

    def call_common_services
      COMMON_SERVICES.each { |s| s.call(submission) }
    end

    def call_non_passported_services
      return if submission.passported?

      NON_PASSPORTED_SERVICES.each { |s| s.call(submission) }
      call_irregular_income
    end

    def call_irregular_income
      # move CreateIrregularIncomesService up into the NON_PASSPORTED_SERVICES when removing the use_new_student_loan feature flag
      return unless Setting.use_new_student_loan?

      CreateIrregularIncomesService.call(submission)
    end
  end
end
