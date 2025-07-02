module HMRC
  class StatusAnalyzer
    delegate :provider,
             :applicant,
             to: :legal_aid_application
    delegate :has_multiple_employments?,
             :hmrc_employment_income?,
             :eligible_employment_payments,
             to: :applicant

    attr_reader :legal_aid_application

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      return :applicant_not_employed if applicant_not_employed? && no_employment_payments?

      return :applicant_unexpected_employment_data if applicant_not_employed? && eligible_employment_payments.any?

      return :applicant_multiple_employments if has_multiple_employments?

      return :applicant_no_hmrc_data unless hmrc_employment_income?

      :applicant_single_employment
    end

    def applicant_not_employed?
      !applicant.employed
    end

    def no_employment_payments?
      eligible_employment_payments.empty?
    end
  end
end
