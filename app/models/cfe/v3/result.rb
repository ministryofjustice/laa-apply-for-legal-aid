module CFE
  module V3
    class Result < CFE::BaseResult
      def assessment_result
        return nil if result_hash[:assessment].nil?

        result_hash[:assessment][:assessment_result]
      end

      def capital_assessment_result
        capital[:assessment_result]
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

      def capital
        result_hash[:assessment][:capital]
      end

      def gross_income
        result_hash[:assessment][:gross_income]
      end

      def total_disposable_income_assessed
        disposable_income[:total_disposable_income]
      end

      def total_gross_income_assessed
        gross_income[:summary][:total_gross_income]
      end

      def gross_income_upper_threshold
        gross_income[:summary][:upper_threshold]
      end

      def disposable_income
        result_hash[:assessment][:disposable_income]
      end

      def disposable_income_lower_threshold
        disposable_income[:lower_threshold]
      end

      def disposable_income_upper_threshold
        disposable_income[:upper_threshold]
      end

      def vehicles
        capital[:capital_items][:vehicles]
      end

      def remarks
        Remarks.new(result_hash[:assessment][:remarks])
      end

      ################################################################
      #                                                              #
      #  INCOME VALUES                                               #
      #                                                              #
      ################################################################

      def mortgage_per_month
        disposable_income[:gross_housing_costs].to_d
      end

      def total_gross_income
        gross_income[:summary][:total_gross_income].to_d
      end

      def maintenance_per_month
        disposable_income[:maintenance_allowance].to_d
      end

      ################################################################
      #                                                              #
      #  CAPITAL ITEMS                                               #
      #                                                              #
      ################################################################

      def non_liquid_capital_items
        capital[:capital_items][:non_liquid].sort_by { |item| item[:description] }
      end

      def liquid_capital_items
        capital[:capital_items][:liquid].sort_by { |item| item[:description] }
      end

      def total_property
        capital[:total_property].to_d
      end

      def total_capital
        capital[:total_capital]
      end

      def total_other_assets
        capital[:total_non_liquid].to_d
      end

      def total_savings
        capital[:total_liquid].to_d
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

      def vehicle
        vehicles.first
      end

      def vehicles?
        vehicles.any?
      end

      def vehicle_value
        vehicle[:value].to_d
      end

      def total_vehicles
        capital[:total_vehicle].to_d
      end

      ################################################################
      #                                                              #
      #  MONTHLY INCOME EQUIVALENTS                                  #
      #                                                              #
      ################################################################

      def monthly_state_benefits
        gross_income[:state_benefits][:monthly_equivalents][:all_sources].to_d
      end

      def mei_friends_or_family
        monthly_income_equivalents[:friends_or_family].to_d
      end

      def mei_maintenance_in
        monthly_income_equivalents[:maintenance_in].to_d
      end

      def mei_property_or_lodger
        monthly_income_equivalents[:property_or_lodger].to_d
      end

      def mei_student_loan
        gross_income[:irregular_income][:monthly_equivalents][:student_loan].to_d
      end

      def mei_pension
        monthly_income_equivalents[:pension].to_d
      end

      def total_monthly_income
        mei_pension + mei_student_loan + mei_property_or_lodger + mei_maintenance_in + mei_friends_or_family + monthly_state_benefits
      end

      def total_monthly_income_including_employment_income
        total_monthly_income
      end

      ################################################################
      #                                                              #
      #  MONTHLY_OUTGOING_EQUIVALENTS                                #
      #                                                              #
      ################################################################

      def moe_housing
        monthly_outgoing_equivalents[:rent_or_mortgage].to_d.abs
      end

      def moe_childcare
        monthly_outgoing_equivalents[:child_care].to_d.abs
      end

      def moe_maintenance_out
        monthly_outgoing_equivalents[:maintenance_out].to_d.abs
      end

      def moe_legal_aid
        monthly_outgoing_equivalents[:legal_aid].to_d.abs
      end

      def total_monthly_outgoings
        moe_housing + moe_childcare + moe_maintenance_out + moe_legal_aid
      end

      def total_monthly_outgoings_including_tax_and_ni
        total_monthly_outgoings
      end

      ################################################################
      #                                                              #
      #  DEDUCTIONS                                                  #
      #                                                              #
      ################################################################

      def dependants_allowance
        deductions[:dependants_allowance].to_d
      end

      def disregarded_state_benefits
        deductions[:disregarded_state_benefits].to_d
      end

      def total_deductions
        dependants_allowance + disregarded_state_benefits
      end

      def total_deductions_including_fixed_employment_allowance
        total_deductions
      end

    private

      def monthly_income_equivalents
        gross_income[:other_income][:monthly_equivalents][:all_sources]
      end

      def monthly_outgoing_equivalents
        disposable_income[:monthly_equivalents][:all_sources]
      end

      def deductions
        # stub out zero values if not found until CFE is updated
        disposable_income[:deductions] || { dependants_allowance: "0.0", disregarded_state_benefits: "0.0" }
      end
    end
  end
end
