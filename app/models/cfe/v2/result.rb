module CFE
  module V2
    class Result < ApplicationRecord # rubocop:disable Metrics/ClassLength
      belongs_to :legal_aid_application
      belongs_to :submission

      # returns the name of the partial to display at the top of the results page
      def overview
        if legal_aid_application.has_restrictions? && !eligible?
          'manual_check_required'
        else
          assessment_result
        end
      end

      def result_hash
        JSON.parse(result, symbolize_names: true)
      end

      def capital_contribution_required?
        assessment_result == 'contribution_required'
      end

      def eligible?
        assessment_result == 'eligible'
      end

      def assessment_result
        result_hash[:assessment_result]
      end

      def capital_contribution
        result_hash[:capital][:capital_contribution].to_d
      end

      def capital
        result_hash[:capital]
      end

      def property
        capital[:capital_items][:properties]
      end

      def main_home
        property[:main_home]
      end

      def gross_income
        result_hash[:gross_income]
      end

      ################################################################
      #                                                              #
      #  INCOME VALUES                                               #
      #                                                              #
      ################################################################

      def monthly_other_income
        gross_income[:value].to_d
      end

      ################################################################
      #                                                              #
      #  OUTGOINGS VALUES                                            #
      #                                                              #
      ################################################################

      def outgoings
        result_hash[:disposable_income][:outgoings]
      end

      def housing_costs
        outgoings[:housing_costs]
      end

      ################################################################
      #                                                              #
      #  MAIN HOME VALUES                                            #
      #                                                              #
      ################################################################

      def main_home_value
        main_home[:value].to_d
      end

      def main_home_outstanding_mortgage
        main_home[:allowable_outstanding_mortgage].to_d * -1
      end

      def main_home_transaction_allowance
        main_home[:transaction_allowance].to_d * -1
      end

      def main_home_equity_disregard
        main_home[:main_home_equity_disregard].to_d * -1
      end

      def main_home_assessed_equity
        main_home[:assessed_equity].to_d.positive? ? main_home[:assessed_equity].to_d : 0.0
      end

      ################################################################
      #                                                              #
      #  ADDITIONAL PROPERTY                                         #
      #                                                              #
      ################################################################

      def additional_property?
        existing_and_not_all_zero?(property[:additional_properties].first)
      end

      def additional_property
        property[:additional_properties].first
      end

      def additional_property_value
        additional_property[:value].to_d
      end

      def additional_property_transaction_allowance
        additional_property[:transaction_allowance].to_d * -1
      end

      def additional_property_mortgage
        additional_property[:allowable_outstanding_mortgage].to_d * -1
      end

      def additional_property_assessed_equity
        additional_property[:assessed_equity].to_d.positive? ? additional_property[:assessed_equity].to_d : 0.0
      end

      ################################################################
      #                                                              #
      #  CAPITAL ITEMS                                               #
      #                                                              #
      ################################################################

      def non_liquid_capital_items
        capital[:non_liquid].sort_by { |item| item[:description] }
      end

      def liquid_capital_items
        capital[:liquid].sort_by { |item| item[:description] }
      end

      def total_property
        capital[:total_property].to_d
      end

      def total_savings
        capital[:total_liquid].to_d
      end

      def total_other_assets
        capital[:total_non_liquid].to_d
      end

      ################################################################
      #                                                              #
      #  VEHICLE   A subset of capital_items                         #
      #                                                              #
      ################################################################

      def vehicle
        result_hash[:capital_items][:vehicles].first
      end

      def vehicles?
        result_hash[:capital_items][:vehicles].any?
      end

      def vehicle_value
        vehicle[:value].to_d
      end

      def vehicle_loan_amount_outstanding
        vehicle[:loan_amount_outstanding].to_d
      end

      def vehicle_disregard
        vehicle_value - vehicle_assessed_amount
      end

      def vehicle_assessed_amount
        vehicle[:assessed_value].to_d
      end

      def total_vehicles
        capital[:total_vehicle].to_d
      end

      ################################################################
      #                                                              #
      #  TOTALS                                                      #
      #                                                              #
      ################################################################

      def pensioner_capital_disregard
        capital[:pensioner_capital_disregard].to_d * -1
      end

      def total_capital_before_pensioner_disregard
        total_property + total_savings + total_vehicles + total_other_assets
      end

      def total_disposable_capital
        [0, (total_capital_before_pensioner_disregard + pensioner_capital_disregard)].max
      end

      ################################################################
      #                                                              #
      #  UTILITY METHODS                                             #
      #                                                              #
      ################################################################

      def existing_and_not_all_zero?(property)
        property.present? && property[:value].to_d > 0.0
      end
    end
  end
end
