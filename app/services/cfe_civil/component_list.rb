module CFECivil
  class ComponentList
    attr_reader :object

    PASSPORTED_SERVICES = [
      Components::Assessment,
      Components::ProceedingTypes,
      Components::Applicant,
      Components::Capitals,
      Components::Vehicles,
      Components::Properties,
      Components::ExplicitRemarks,
      Components::Partner,
    ].freeze

    NON_PASSPORTED_WITH_BANK_TRANSACTIONS_SERVICES = [
      Components::Assessment,
      Components::ProceedingTypes,
      Components::Applicant,
      Components::Capitals,
      Components::Vehicles,
      Components::Properties,
      Components::ExplicitRemarks,
      Components::Dependants,
      Components::Outgoings,
      Components::StateBenefits,
      Components::OtherIncome,
      Components::IrregularIncomes,
      Components::Employments,
      Components::RegularTransactions,
      Components::CashTransactions,
      Components::Partner,
    ].freeze

    NON_PASSPORTED_WITH_REGULAR_TRANSACTIONS_SERVICES = [
      Components::Assessment,
      Components::ProceedingTypes,
      Components::Applicant,
      Components::Capitals,
      Components::Vehicles,
      Components::Properties,
      Components::ExplicitRemarks,
      Components::Dependants,
      Components::IrregularIncomes,
      Components::Employments,
      Components::RegularTransactions,
      Components::CashTransactions,
      Components::Partner,
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
      elsif object.non_passported? && object.client_uploading_bank_statements?
        NON_PASSPORTED_WITH_REGULAR_TRANSACTIONS_SERVICES
      elsif object.non_passported?
        NON_PASSPORTED_WITH_BANK_TRANSACTIONS_SERVICES
      else
        raise ArgumentError, "#{object.class} does not have a set of CFE submission services!"
      end
    end
  end
end
