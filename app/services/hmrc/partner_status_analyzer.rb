module HMRC
  class PartnerStatusAnalyzer < StatusAnalyzer
    delegate :provider,
             :partner,
             to: :legal_aid_application
    delegate :has_multiple_employments?,
             :hmrc_employment_income?,
             :eligible_employment_payments,
             to: :partner

    attr_reader :legal_aid_application

    def call
      partner.employed? ? employed_status : not_employed_status
    end

  private

    def employed_status
      return :partner_employed_no_nino unless partner.has_national_insurance_number?
      return :partner_employed_hmrc_unavailable if partner.hmrc_responses.empty?
      return :partner_unexpected_no_employment_data if no_employment_payments?
      return :partner_multiple_employments if has_multiple_employments?

      :partner_single_employment
    end

    def not_employed_status
      return :partner_not_employed_no_nino unless partner.has_national_insurance_number?
      return :partner_not_employed_hmrc_unavailable if partner.hmrc_responses.empty?
      return :partner_not_employed_no_payments if no_employment_payments?

      :partner_unexpected_employment_data if eligible_employment_payments.any?
    end

    def no_employment_payments?
      eligible_employment_payments.empty?
    end
  end
end
