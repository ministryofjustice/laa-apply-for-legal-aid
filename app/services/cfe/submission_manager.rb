module CFE
  class SubmissionManager
    include ::DurationLogger

    PASSPORTED_SERVICES = [
      CreateAssessmentService,
      CreateProceedingTypesService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService,
    ].freeze

    NON_PASSPORTED_SERVICES = [
      CreateAssessmentService,
      CreateProceedingTypesService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService,
      CreateDependantsService,
      CreateOutgoingsService,
      CreateStateBenefitsService,
      CreateOtherIncomeService,
      CreateIrregularIncomesService,
      CreateEmploymentsService,
      CreateCashTransactionsService,
    ].freeze

    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    attr_reader :legal_aid_application_id

    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      call_passported_services
      call_non_passported_services
      ObtainAssessmentResultService.call(submission)
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

    def call_passported_services
      return unless submission.passported?

      PASSPORTED_SERVICES.each do |service|
        make_logged_call_to service
      end
    end

    def call_non_passported_services
      return if submission.passported?

      NON_PASSPORTED_SERVICES.each do |service|
        make_logged_call_to service
      end
    end

    def make_logged_call_to(service)
      log_duration("CFE Submission :: call to #{service} for #{legal_aid_application_id}") do
        service.call(submission)
      end
    end
  end
end
