module CFE
  module V6
    class Result < CFE::V4::Result
      def partner_gross_income_breakdown
        assessment[:partner_gross_income]
      end

      ################################################################
      #                                                              #
      #  EMPLOYMENT_INCOME                                           #
      #                                                              #
      ################################################################

      def disposable_income_summary(partner: false)
        partner ? result_summary[:partner_disposable_income] : result_summary[:disposable_income]
      end

      def employment_income(partner: false)
        disposable_income_summary(partner:)[:employment_income]
      end

      def employment_income_gross_income(partner: false)
        employment_income(partner:)[:gross_income] || 0.0
      end

      def employment_income_benefits_in_kind(partner: false)
        employment_income(partner:)[:benefits_in_kind] || 0.0
      end

      def employment_income_tax(partner: false)
        employment_income(partner:)[:tax] || 0.0
      end

      def employment_income_national_insurance(partner: false)
        employment_income(partner:)[:national_insurance] || 0.0
      end

      def employment_income_fixed_employment_deduction(partner: false)
        employment_income(partner:)[:fixed_employment_deduction] || 0.0
      end

      def employment_income_net_employment_income(partner: false)
        employment_income(partner:)[:net_employment_income] || 0.0
      end

      def partner_jobs
        partner_gross_income_breakdown[:employment_income]
      end

      def partner_jobs?
        partner_jobs&.any?
      end
    end
  end
end
