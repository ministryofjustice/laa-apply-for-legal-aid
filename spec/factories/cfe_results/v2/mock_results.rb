module CFEResults
  module V2
    class MockResults
      def self.eligible # rubocop:disable Metrics/MethodLength
        {
        #    NEED TO ADD IN AN ELIGIBLE RESULTSET
        }
      end

      def self.not_eligible
        eligible.merge assessment_result: 'not_eligible'
      end

      def self.contribution_required
        new_capital_section = eligible[:capital]
        new_capital_section[:capital_contribution] = '465.66'
        eligible.merge assessment_result: 'contribution_required', capital: new_capital_section
      end

      def self.no_additional_properties
        result = eligible
        result[:property][:additional_properties] = []
        result
      end

      def self.with_additional_properties
        result = eligible
        property = {
          value: '350255.0',
          transaction_allowance: '012550',
          allowable_outstanding_mortgage: '45000.0',
          percentage_owned: '100.0',
          assessed_equity: '224000'
        }
        result[:property][:additional_properties] = [property]
        result
      end
    end
  end
end
