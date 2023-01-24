module CFE
  class ServiceSet
    attr_reader :object

    PASSPORTED_SERVICES = [
      CreateProceedingTypesService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService,
    ].freeze

    NON_PASSPORTED_WITH_BANK_TRANSACTIONS_SERVICES = [
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

    NON_PASSPORTED_WITH_REGULAR_TRANSACTIONS_SERVICES = [
      CreateProceedingTypesService,
      CreateApplicantService,
      CreateCapitalsService,
      CreateVehiclesService,
      CreatePropertiesService,
      CreateExplicitRemarksService,
      CreateDependantsService,
      CreateIrregularIncomesService,
      CreateEmploymentsService,
      CreateRegularTransactionsService,
      CreateCashTransactionsService,
    ].freeze

    def self.call(object)
      new(object).call
    end

    def initialize(object)
      @object = object
    end

    def call
      service_set
    end

  private

    def service_set
      if object.passported?
        PASSPORTED_SERVICES
      elsif object.non_passported? && object.uploading_bank_statements?
        NON_PASSPORTED_WITH_REGULAR_TRANSACTIONS_SERVICES
      elsif object.non_passported?
        NON_PASSPORTED_WITH_BANK_TRANSACTIONS_SERVICES
      else
        raise ArgumentError, "#{object.class} does not have a set of CFE submission services!"
      end
    end
  end
end
