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
    end
  end
end
