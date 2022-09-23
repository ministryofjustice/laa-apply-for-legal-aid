module CFE
  class ServiceSet
    attr_reader :object

    PASSPORTED_SERVICES = [
      CreateAssessmentService,
      CreateProceedingTypesService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService,
      ObtainAssessmentResultService,
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
      ObtainAssessmentResultService,
    ].freeze

    def self.call(object)
      new(object).call
    end

    def initialize(object)
      @object = object
    end

    def call
      if object.passported?
        PASSPORTED_SERVICES
      elsif object.non_passported?
        NON_PASSPORTED_SERVICES
      else
        raise ArgumentError, "#{object.class} does not have a set of CFE submission services!"
      end
    end
  end
end
