module CFE
  module V4
    class Result < CFE::BaseResult # rubocop:disable Metrics/ClassLength
      def assessment_result
        return nil if result_summary.nil?

        overall_result[:result]
      end

      def overall_result
        result_summary[:overall_result]
      end

      def result_summary
        result_hash[:result_summary]
      end

      def assessment
        result_hash[:assessment]
      end

      def capital_contribution_required?
        capital_contribution > 0.0
      end

      def capital_contribution
        overall_result[:capital_contribution]
      end

      def income_contribution_required?
        income_contribution > 0.0
      end

      def income_contribution
        overall_result[:income_contribution]
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

      def non_liquid_capital_items
        capital[:capital_items][:non_liquid].sort_by { |item| item[:description] }
      end

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

      def vehicle
        vehicles.first
      end

      def vehicles?
        vehicles.any?
      end

      def vehicle_value
        vehicle[:value]
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

      ################################################################
      #                                                              #
      #  MONTHLY_OUTGOING_EQUIVALENTS                                #
      #                                                              #
      ################################################################

      def moe_housing
        monthly_outgoing_equivalents[:rent_or_mortgage].abs
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

      private

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
