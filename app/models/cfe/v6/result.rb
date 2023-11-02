module CFE
  module V6
    class Result < CFE::V4::Result
      def gross_income_results
        gross_income_proceeding_types.pluck(:result)
      end

      def disposable_income_results
        disposable_income_proceeding_types.pluck(:result)
      end

      def capital_proceeding_types
        capital_summary[:proceeding_types]
      end

      def capital_results
        capital_proceeding_types.pluck(:result)
      end

      def ineligible_gross_income?
        gross_income_results.all?("ineligible")
      end

      def ineligible_disposable_income?
        disposable_income_results.all?("ineligible")
      end

      def ineligible_disposable_capital?
        capital_results.all?("ineligible")
      end

      def partner_gross_income_breakdown
        assessment[:partner_gross_income]
      end

      def gross_income_breakdown(partner: false)
        partner ? assessment[:partner_gross_income] : assessment[:gross_income]
      end

      def disposable_income_summary(partner: false)
        partner ? result_summary[:partner_disposable_income] : result_summary[:disposable_income]
      end

      def disposable_income_breakdown(partner: false)
        partner ? assessment[:partner_disposable_income] : assessment[:disposable_income]
      end

      ################################################################
      #                                                              #
      #  EMPLOYMENT_INCOME                                           #
      #                                                              #
      ################################################################

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
        gross_income_breakdown(partner: true)[:employment_income]
      end

      def partner_jobs?
        partner_jobs&.any?
      end

      ################################################################
      #                                                              #
      #  MONTHLY INCOME EQUIVALENTS                                  #
      #                                                              #
      ################################################################

      def monthly_income_equivalents(partner: false)
        gross_income_breakdown(partner:)[:other_income][:monthly_equivalents][:all_sources]
      end

      def monthly_state_benefits(partner: false)
        gross_income_breakdown(partner:)[:state_benefits][:monthly_equivalents][:all_sources]
      end

      def mei_friends_or_family(partner: false)
        monthly_income_equivalents(partner:)[:friends_or_family]
      end

      def mei_maintenance_in(partner: false)
        monthly_income_equivalents(partner:)[:maintenance_in]
      end

      def mei_property_or_lodger(partner: false)
        monthly_income_equivalents(partner:)[:property_or_lodger]
      end

      def mei_student_loan(partner: false)
        gross_income_breakdown(partner:)[:irregular_income][:monthly_equivalents][:student_loan]
      end

      def mei_pension(partner: false)
        monthly_income_equivalents(partner:)[:pension]
      end

      # def total_monthly_income(partner: false)
      #   mei_pension(partner:) + mei_student_loan(partner:)
      #   + mei_property_or_lodger(partner:) + mei_maintenance_in(partner:)
      #   + mei_friends_or_family(partner:) + monthly_state_benefits(partner:)
      # end
      #
      # def total_monthly_income_including_employment_income(partner: false)
      #   total_monthly_income(partner:) + employment_income_gross_income(partner:)
      # end

      ################################################################
      #                                                              #
      #  MONTHLY_OUTGOING_EQUIVALENTS                                #
      #                                                              #
      ################################################################

      def monthly_outgoing_equivalents(partner: false)
        disposable_income_breakdown(partner:)[:monthly_equivalents][:all_sources]
      end

      def moe_housing(partner: false)
        disposable_income_summary(partner:)[:net_housing_costs].abs
      end

      def moe_childcare(partner: false)
        monthly_outgoing_equivalents(partner:)[:child_care].abs
      end

      def moe_maintenance_out(partner: false)
        monthly_outgoing_equivalents(partner:)[:maintenance_out].abs
      end

      def moe_legal_aid(partner: false)
        monthly_outgoing_equivalents(partner:)[:legal_aid].abs
      end

      def total_monthly_outgoings(partner: false)
        moe_housing(partner:) + moe_childcare(partner:) + moe_maintenance_out(partner:) + moe_legal_aid(partner:)
      end

      def total_monthly_outgoings_including_tax_and_ni(partner: false)
        total_monthly_outgoings(partner:) - employment_income_tax(partner:) - employment_income_national_insurance(partner:)
      end
    end
  end
end
