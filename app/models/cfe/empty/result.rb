module CFE
  module Empty
    class Result < CFE::BaseResult
      def assessment_result
        return nil if result_summary.nil?

        overall_result[:result]
      end

      def overall_result
        result_summary[:overall_result]
      end

      def result_summary
        CFE::Empty::EmptyResult.blank_cfe_result[:result_summary]
      end

      def assessment
        CFE::Empty::EmptyResult.blank_cfe_result[:assessment]
      end

      def disposable_income
        disposable_income_summary[:total_disposable_income]
      end

      def capital_contribution_required?
        capital_assessment_result == "contribution_required"
      end

      def capital_contribution
        capital[:capital_contribution].to_d
      end

      def income_assessment_result
        disposable_income[:assessment_result]
      end

      def income_contribution_required?
        income_assessment_result == "contribution_required"
      end

      def income_contribution
        disposable_income[:income_contribution].to_d
      end

      def capital_summary
        result_summary[:capital]
      end

      def total_other_assets
        capital_summary[:total_non_liquid]
      end

      def total_savings
        capital_summary[:total_liquid]
      end

      def capital
        assessment[:capital]
      end

      def gross_income_breakdown
        assessment[:gross_income]
      end

      def gross_income_summary
        result_summary[:gross_income]
      end

      def gross_income_upper_threshold
        min_threshold(gross_income_summary[:proceeding_types], :upper_threshold)
      end

      def total_disposable_income_assessed
        disposable_income_summary[:total_disposable_income]
      end

      def total_gross_income_assessed
        gross_income_summary[:total_gross_income]
      end

      def gross_income_proceeding_types
        gross_income_summary[:proceeding_types]
      end

      def disposable_income_summary
        result_summary[:disposable_income]
      end

      def disposable_income_breakdown
        assessment[:disposable_income]
      end

      def disposable_income_proceeding_types
        disposable_income_summary[:proceeding_types]
      end

      def disposable_income_lower_threshold
        min_threshold(disposable_income_summary[:proceeding_types], :lower_threshold)
      end

      def disposable_income_upper_threshold
        min_threshold(disposable_income_summary[:proceeding_types], :upper_threshold)
      end

      def vehicles
        capital[:capital_items][:vehicles]
      end

      def remarks
        Remarks.new(assessment[:remarks])
      end

      ################################################################
      #                                                              #
      #  INCOME VALUES                                               #
      #                                                              #
      ################################################################

      def total_gross_income
        total_gross_income_assessed
      end

      def mortgage_per_month
        disposable_income_summary[:gross_housing_costs]
      end

      def maintenance_per_month
        disposable_income_summary[:maintenance_allowance]
      end

      ################################################################
      #                                                              #
      #  CAPITAL ITEMS                                               #
      #                                                              #
      ################################################################

      def liquid_capital_items
        capital[:capital_items][:liquid].sort_by { |item| item[:description] }
      end

      def total_property
        capital_summary[:total_property]
      end

      def total_capital
        result_summary[:capital][:total_capital]
      end

      def property
        capital[:capital_items][:properties]
      end

      def main_home
        property[:main_home]
      end

      def additional_properties
        property[:additional_properties]
      end

      ################################################################
      #                                                              #
      #  VEHICLE                                                     #
      #                                                              #
      ################################################################

      def vehicles?
        vehicles.any?
      end

      def total_vehicles
        capital_summary[:total_vehicle]
      end

      ################################################################
      #                                                              #
      #  MONTHLY INCOME EQUIVALENTS                                  #
      #                                                              #
      ################################################################

      def monthly_state_benefits
        gross_income_breakdown[:state_benefits][:monthly_equivalents][:all_sources]
      end

      def mei_friends_or_family
        monthly_income_equivalents[:friends_or_family]
      end

      def mei_maintenance_in
        monthly_income_equivalents[:maintenance_in]
      end

      def mei_property_or_lodger
        monthly_income_equivalents[:property_or_lodger]
      end

      def mei_student_loan
        gross_income_breakdown[:irregular_income][:monthly_equivalents][:student_loan]
      end

      def mei_pension
        monthly_income_equivalents[:pension]
      end

      def total_monthly_income
        mei_pension + mei_student_loan + mei_property_or_lodger + mei_maintenance_in + mei_friends_or_family + monthly_state_benefits
      end

      def total_monthly_income_including_employment_income
        total_monthly_income + employment_income_gross_income
      end

      ################################################################
      #                                                              #
      #  MONTHLY_OUTGOING_EQUIVALENTS                                #
      #                                                              #
      ################################################################

      def moe_housing
        disposable_income_summary[:net_housing_costs].abs
      end

      def moe_childcare
        monthly_outgoing_equivalents[:child_care].abs
      end

      def moe_maintenance_out
        monthly_outgoing_equivalents[:maintenance_out].abs
      end

      def moe_legal_aid
        monthly_outgoing_equivalents[:legal_aid].abs
      end

      def total_monthly_outgoings
        moe_housing + moe_childcare + moe_maintenance_out + moe_legal_aid
      end

      def total_monthly_outgoings_including_tax_and_ni
        total_monthly_outgoings - employment_income_tax - employment_income_national_insurance
      end

      ################################################################
      #                                                              #
      #  DEDUCTIONS                                                  #
      #                                                              #
      ################################################################

      def dependants_allowance
        deductions[:dependants_allowance]
      end

      def disregarded_state_benefits
        deductions[:disregarded_state_benefits]
      end

      def total_deductions
        dependants_allowance + disregarded_state_benefits
      end

      def total_deductions_including_fixed_employment_allowance
        total_deductions - employment_income_fixed_employment_deduction
      end

      ################################################################
      #                                                              #
      #  EMPLOYMENT_INCOME                                           #
      #                                                              #
      ################################################################

      def employment_income
        disposable_income_summary[:employment_income]
      end

      def employment_income_gross_income
        employment_income[:gross_income] || 0.0
      end

      def employment_income_tax
        employment_income[:tax] || 0.0
      end

      def employment_income_national_insurance
        employment_income[:national_insurance] || 0.0
      end

      def employment_income_fixed_employment_deduction
        employment_income[:fixed_employment_deduction] || 0.0
      end

    private

      def min_threshold(proceeding_types_array, threshold_method)
        threshold = proceeding_types_array.map { |pt| pt[threshold_method] }.min
        threshold == MAX_VALUE ? "N/a" : threshold
      end

      def monthly_income_equivalents
        gross_income_breakdown[:other_income][:monthly_equivalents][:all_sources]
      end

      def monthly_outgoing_equivalents
        disposable_income_breakdown[:monthly_equivalents][:all_sources]
      end

      def deductions
        # stub out zero values if not found until CFE is updated
        disposable_income_breakdown[:deductions] || { dependants_allowance: 0.0, disregarded_state_benefits: 0.0 }
      end
    end
  end
end
