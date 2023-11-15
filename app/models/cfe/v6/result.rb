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
        gross_income_results.all? { |result| result == 'ineligible' }
      end
    
      def ineligible_disposable_income?
        disposable_income_results.all? { |result| result == 'ineligible' }
      end
    
      def ineligible_disposable_capital?
        capital_results.all? { |result| result == 'ineligible' }
      end
    end
  end
end
