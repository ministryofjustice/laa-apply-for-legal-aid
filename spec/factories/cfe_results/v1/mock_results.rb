module CFEResults
  module V1
    class MockResults
      def self.eligible # rubocop:disable Metrics/MethodLength
        {
          assessment_result: 'eligible',
          applicant: {
            receives_qualifying_benefit: true,
            age_at_submission: 39
          },
          capital: {
            total_liquid: '350.0',
            total_non_liquid: '0.0',
            pensioner_capital_disregard: '0.0',
            total_capital: '350.0',
            capital_contribution: '0.0',
            liquid_capital_items: [
              {
                description: 'Off-line bank accounts',
                value: '350.0'
              }
            ],
            non_liquid_capital_items: []
          },
          property: {
            total_mortgage_allowance: '100000.0',
            total_property: '-100000.0',
            main_home: { value: '0.0',
                         transaction_allowance: '0.0',
                         allowable_outstanding_mortgage: '0.0',
                         percentage_owned: '0.0',
                         net_equity: '0.0',
                         main_home_equity_disregard: '100000.0',
                         assessed_equity: '-100000.0',
                         shared_with_housing_assoc: false },
            additional_properties: [
              {
                value: '0.0',
                transaction_allowance: '0.0',
                allowable_outstanding_mortgage: '0.0',
                percentage_owned: '0.0',
                assessed_equity: '0.0'
              }
            ]
          },
          vehicles: {
            total_vehicle: '0.0',
            vehicles: [
              {
                in_regular_use: true,
                value: '900.0',
                loan_amount_outstanding: '0.0',
                date_of_purchase: '2013-06-01',
                included_in_assessment: false,
                assessed_value: '0.0'
              }
            ]
          }
        }
      end

      def self.not_eligible
        eligible.merge assessment_result: 'not_eligible'
      end

      def self.contribution_required
        puts ">>>>>>>>>>>> MOCKRESULT contribution requiered #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
        new_capital_section = eligible[:capital]
        new_capital_section[:capital_contribution] = '465.66'
        eligible.merge assessment_result: 'contribution_required', capital: new_capital_section
      end

      def self.no_capital
        new_capital_section = eligible[:capital]
        new_capital_section[:total_liquid] = '0.0'
        new_capital_section[:total_capital] = '0.0'
        eligible.merge capital: new_capital_section
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
