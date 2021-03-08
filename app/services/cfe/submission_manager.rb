module CFE
  class SubmissionManager
    COMMON_SERVICES = [
      CreateAssessmentService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService
    ].freeze

    NON_PASSPORTED_SERVICES = [
      CreateDependantsService,
      CreateOutgoingsService,
      CreateStateBenefitsService,
      CreateOtherIncomeService,
      CreateIrregularIncomesService
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
      CreateCashTransactionsService.call(submission) unless submission.passported?
      ObtainAssessmentResultService.call(submission)
      true
    rescue SubmissionError => e
      submission.error_message = e.message
      Sentry.capture_exception(e)
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

      NON_PASSPORTED_SERVICES.each do |s|
        s.call(submission)
      end
    end
  end
end
