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
      return :partner_not_employed if partner_not_employed? && no_employment_payments?

      return :partner_unexpected_employment_data if partner_not_employed? && eligible_employment_payments.any?

      return :partner_multiple_employments if has_multiple_employments?

      return :partner_no_hmrc_data unless hmrc_employment_income?

      :partner_single_employment
    end

  private

    def partner_not_employed?
      !partner.employed
    end

    def no_employment_payments?
      partner.eligible_employment_payments.empty?
    end
  end
end
