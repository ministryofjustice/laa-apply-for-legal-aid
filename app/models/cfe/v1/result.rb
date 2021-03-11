## Do not delete: This file is no longer in use but is needed for the single
## table inheritance table cfe_results to continue to function correctly.
# :nocov:
module CFE
  module V1
    class Result < CFE::BaseResult # rubocop:disable Metrics/ClassLength
      def assessment_result
        result_hash[:assessment_result]
      end

      def income_contribution_required?
        false
      end

      def capital_contribution_required?
        result_hash[:assessment_result] == 'contribution_required'
      end

      def capital_contribution
        result_hash[:capital][:capital_contribution].to_d
      end

      def capital
        result_hash[:capital]
      end

      def property
        result_hash[:property]
      end

      ################################################################
      #                                                              #
      #  VEHICLE                                                     #
      #                                                              #
      ################################################################

      def vehicle
        result_hash[:vehicles][:vehicles].first
      end

      def vehicles?
        result_hash[:vehicles][:vehicles].any?
      end

      def vehicle_value
        vehicle[:value].to_d
      end

      def total_vehicles
        result_hash[:vehicles][:total_vehicle].to_d
      end

      ################################################################
      #                                                              #
      #  CAPITAL ITEMS                                               #
      #                                                              #
      ################################################################

      def non_liquid_capital_items
        capital[:non_liquid_capital_items].sort_by { |item| item[:description] }
      end

      def liquid_capital_items
        capital[:liquid_capital_items].sort_by { |item| item[:description] }
      end

      def total_property
        property[:total_property].to_d
      end
    end
  end
end
# :nocov:
