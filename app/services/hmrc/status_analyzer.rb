module HMRC
  class StatusAnalyzer
    delegate :provider,
             :applicant,
             :has_multiple_employments?,
             :hmrc_employment_income?,
             :eligible_employment_payments,
             to: :legal_aid_application

    attr_reader :legal_aid_application

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      return :applicant_not_employed if applicant_not_employed && no_employment_payments

      return :unexpected_employment_data if applicant_not_employed && eligible_employment_payments.any?

      return :hmrc_multiple_employments if has_multiple_employments?

      return :no_hmrc_data unless hmrc_employment_income?

      :hmrc_single_employment
    end

    def applicant_not_employed
      !applicant.employed
    end

    def no_employment_payments
      eligible_employment_payments.empty?
    end
  end
end
