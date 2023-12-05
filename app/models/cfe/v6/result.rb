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

      def gross_income_summary(partner: false)
        partner ? result_summary[:partner_gross_income] : result_summary[:gross_income]
      end

      def total_gross_income(partner: false)
        total_gross_income_assessed(partner:)
      end

      def total_gross_income_assessed(partner: false)
        gross_income_summary(partner:)[:total_gross_income]
      end

      def total_disposable_income_assessed(partner: false)
        client_total = disposable_income_summary[:total_disposable_income]
        partner_total = partner ? disposable_income_summary(partner:)[:total_disposable_income] : 0.0
        client_total + partner_total
      end

      ################################################################
      #                                                              #
      #  DISPOSABLE INCOME                                           #
      #                                                              #
      ################################################################

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
        unless assessment.key?(:partner_gross_income)
          return []
        end

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

      def total_monthly_income(partner: false)
        mei_pension(partner:) + mei_student_loan(partner:) + mei_property_or_lodger(partner:) + mei_maintenance_in(partner:) + mei_friends_or_family(partner:) + monthly_state_benefits(partner:)
      end

      def total_monthly_income_including_employment_income(partner: false)
        client_total = total_monthly_income + employment_income_gross_income
        partner_total = partner ? total_monthly_income(partner:) + employment_income_gross_income(partner:) : 0.0
        client_total + partner_total
      end

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
        client_total = total_monthly_outgoings - employment_income_tax - employment_income_national_insurance
        partner_total = partner ? (total_monthly_outgoings(partner:) - employment_income_tax(partner:) - employment_income_national_insurance(partner:)) : 0.0
        client_total + partner_total
      end

      ################################################################
      #                                                              #
      #  DEDUCTIONS                                                  #
      #                                                              #
      ################################################################

      def partner_allowance
        disposable_income_summary.key?(:partner_allowance) ? disposable_income_summary[:partner_allowance] : 0.0
      end

      def total_deductions
        dependants_allowance + disregarded_state_benefits + partner_allowance
      end

      def total_deductions_including_fixed_employment_allowance
        employment_deduction = employment_income_fixed_employment_deduction
        if partner_jobs?
          employment_deduction * 2
        end
        total_deductions - employment_deduction
      end

      ################################################################
      #                                                              #
      #  CAPITAL                                                     #
      #                                                              #
      ################################################################

      def capital_summary(partner: false)
        partner ? result_summary[:partner_capital] : result_summary[:capital]
      end

      def partner_capital
        assessment[:partner_capital]
      end

      def partner_capital?
        assessment.key?(:partner_capital)
      end

      def current_accounts
        accounts = liquid_capital_items.select { |item| item[:description].downcase!.include?("current accounts") }
        accounts.sum { |account| account[:value] }
      end

      def savings_accounts
        accounts = liquid_capital_items.select { |item| item[:description].downcase!.include?("savings accounts") }
        accounts.sum { |account| account[:value] }
      end

      def liquid_capital_items
        client_items = capital[:capital_items][:liquid].sort_by { |item| item[:description] }
        partner_items = partner_capital? ? partner_capital[:capital_items][:liquid] : []
        client_items.concat(partner_items).sort_by { |item| item[:description] }
      end

      def total_savings
        client_savings = capital_summary[:total_liquid]
        partner_savings = partner_capital? ? capital_summary(partner: true)[:total_liquid] : 0.0
        client_savings + partner_savings
      end

      def total_capital
        client_total = result_summary[:capital][:total_capital]
        partner_total = partner_capital? ? result_summary[:partner_capital][:total_capital] : 0.0
        client_total + partner_total
      end

      ################################################################
      #                                                              #
      #  TOTALS                                                      #
      #                                                              #
      ################################################################

      def total_capital_before_pensioner_disregard
        total_property + total_savings + total_vehicles + total_other_assets
      end

      def total_disposable_capital
        [0, (total_capital_before_pensioner_disregard + pensioner_capital_disregard)].max
      end
    end
  end
end
