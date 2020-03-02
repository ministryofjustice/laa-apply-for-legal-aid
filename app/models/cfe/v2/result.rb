module CFE
  module V2
    class Result < CFE::BaseResult # rubocop:disable Metrics/ClassLength
      def assessment_result
        result_hash[:assessment][:assessment_result]
      end

      def capital_contribution
        capital[:capital_contribution].to_d
      end

      def capital
        result_hash[:assessment][:capital]
      end

      def property
        capital[:capital_items][:properties]
      end

      def gross_income
        result_hash[:assessment][:gross_income]
      end

      def disposable_income
        result_hash[:assessment][:disposable_income]
      end

      def outgoings
        result_hash[:assessment][:disposable_income][:outgoings]
      end

      def vehicles
        capital[:capital_items]
      end

      ################################################################
      #                                                              #
      #  INCOME VALUES                                               #
      #                                                              #
      ################################################################

      def monthly_other_income
        gross_income[:monthly_other_income].to_d
      end

      def maintenance_per_month
        # TODO: monitor this... is it actually monthly or a gross amount?
        # this will need testing once full CCMS submission for non passported
        # is working.  Either this will need amending or this comment can be deleted
        disposable_income[:maintenance_allowance].to_d
      end

      ################################################################
      #                                                              #
      #  OUTGOINGS VALUES                                            #
      #                                                              #
      ################################################################

      def housing_costs
        outgoings[:housing_costs].first
      end

      def childcare_costs
        outgoings[:childcare_costs].first
      end

      def maintenance_costs
        outgoings[:maintenance_costs].first
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

      ################################################################
      #                                                              #
      #  VEHICLE                                                     #
      #                                                              #
      ################################################################

      def vehicle
        vehicles[:vehicles].first
      end

      def vehicles?
        vehicles[:vehicles].any?
      end

      def vehicle_value
        vehicle[:value].to_d
      end

      def total_vehicles
        capital[:total_vehicle].to_d
      end
    end
  end
end
