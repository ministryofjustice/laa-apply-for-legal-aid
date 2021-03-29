module LegalAidApplications
  class CalculationDateService
    attr_accessor :legal_aid_application

    delegate(
      :used_delegated_functions_on, :used_delegated_functions?, :chances_of_success, :applicant_receives_benefit?, :transaction_period_finish_on,
      to: :legal_aid_application
    )

    def self.call(*args)
      new(*args).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      return used_delegated_functions_on if used_delegated_functions?

      return chances_of_success&.submitted_at&.to_date || Time.zone.today if applicant_receives_benefit?

      transaction_period_finish_on
    end
  end
end
