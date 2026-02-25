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
      applicant.employed? ? employed_status : not_employed_status
    end

  private

    def employed_status
      return :applicant_employed_no_nino unless applicant.has_national_insurance_number?
      return :applicant_employed_hmrc_unavailable if applicant.hmrc_responses.empty?
      return :applicant_unexpected_no_employment_data if no_employment_payments?
      return :applicant_multiple_employments if has_multiple_employments?

      :applicant_single_employment
    end

    def not_employed_status
      return :applicant_not_employed_no_nino unless applicant.has_national_insurance_number?
      return :applicant_not_employed_hmrc_unavailable if applicant.hmrc_responses.empty?
      return :applicant_not_employed_no_payments if no_employment_payments?

      :applicant_unexpected_employment_data if eligible_employment_payments.any?
    end

    def applicant_not_employed?
      !applicant.employed?
    end

    def no_employment_payments?
      eligible_employment_payments.empty?
    end
  end
end
