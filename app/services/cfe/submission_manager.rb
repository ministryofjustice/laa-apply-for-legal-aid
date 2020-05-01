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
      ObtainAssessmentResultService.call(submission)
      true
    rescue SubmissionError => e
      submission.error_message = e.message
      submission.fail!
      process_error(e)
      false
    end

    def submission
      @submission ||= Submission.create!(legal_aid_application_id: legal_aid_application_id)
    end
    
    private

    def process_error(error)
      Raven.capture_exception(error)
      SlackAlertSenderWorker.perform_async(format_error(error))
      false
    end

    def format_error(error)
      [
        '*CFE::SubmissionManager REQUEST ERROR*',
        'An error has been raised by the CFE::SubmissionManager and logged to Sentry',
        "*Application* #{legal_aid_application_id}",
        "#{error.class}: #{error.message}"
      ].join("\n")
    end
  end
end
