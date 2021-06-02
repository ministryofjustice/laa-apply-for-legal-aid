module CFEResults
  module V4
    class MockResults # rubocop:disable Metrics/ClassLength
      def self.eligible # rubocop:disable Metrics/MethodLength
        {
          version: '4',
          timestamp: '2021-05-26T12:51:56.329Z',
          success: true,
          result_summary: {
            overall_result: {
              result: 'eligible',
              capital_contribution: 0.0,
              income_contribution: 0.0,
              matter_types: [{
                matter_type: 'domestic_abuse',
                result: 'eligible'
              }],
              proceeding_types: [
                {
                  ccms_code: 'DA006',
                  result: 'eligible'
                },
                {
                  ccms_code: 'DA002',
                  result: 'eligible'
                }
              ]
            },
            gross_income: {
              total_gross_income: 0.0,
              proceeding_types: [
                {
                  ccms_code: 'DA006',
                  upper_threshold: 999_999_999_999.0,
                  result: 'pending'
                },
                {
                  ccms_code: 'DA002',
                  upper_threshold: 999_999_999_999.0,
                  result: 'pending'
                }
              ]
            },
            disposable_income: {
              dependant_allowance: 0.0,
              gross_housing_costs: 0.0,
              housing_benefit: 0.0,
              net_housing_costs: 0.0,
              maintenance_allowance: 0.0,
              total_outgoings_and_allowances: 0.0,
              total_disposable_income: 0.0,
              income_contribution: 0.0,
              proceeding_types: [
                {
                  ccms_code: 'DA006',
                  upper_threshold: 999_999_999_999.0,
                  lower_threshold: 315.0,
                  result: 'pending'
                },
                {
                  ccms_code: 'DA002',
                  upper_threshold: 999_999_999_999.0,
                  lower_threshold: 315.0,
                  result: 'pending'
                }
              ]
            },
            capital: {
              total_liquid: 12.0,
              total_non_liquid: 12.0,
              total_vehicle: 120.0,
              total_property: 0.0,
              total_mortgage_allowance: 999_999_999_999.0,
              total_capital: 144.0,
              pensioner_capital_disregard: 0.0,
              capital_contribution: 0.0,
              assessed_capital: 144.0,
              proceeding_types: [
                {
                  ccms_code: 'DA006',
                  lower_threshold: 3000.0,
                  upper_threshold: 999_999_999_999.0,
                  result: 'eligible'
                },
                {
                  ccms_code: 'DA002',
                  lower_threshold: 3000.0,
                  upper_threshold: 999_999_999_999.0,
                  result: 'eligible'
                }
              ]
            }
          },
          assessment: {
            id: 'b60d9312-b77b-4c5f-aa79-ba8508800c59',
            client_reference_id: 'L-C36-J5T',
            submission_date: '2021-05-26',
            applicant: {
              date_of_birth: '1980-01-10',
              involvement_type: 'applicant',
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
              self_employed: false
            },
            gross_income: {
              irregular_income: {
                monthly_equivalents: {
                  student_loan: 0.0
                }
              },
              state_benefits: {
                monthly_equivalents: {
                  all_sources: 0.0,
                  cash_transactions: 0.0,
                  bank_transactions: []
                }
              },
              other_income: {
                monthly_equivalents: {
                  all_sources: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0
                  },
                  bank_transactions: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0
                  },
                  cash_transactions: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0
                  }
                }
              }
            },
            disposable_income: {
              monthly_equivalents: {
                all_sources: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0
                },
                bank_transactions: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0
                },
                cash_transactions: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0
                }
              },
              childcare_allowance: 0.0,
              deductions: {
                dependants_allowance: 0.0,
                disregarded_state_benefits: 0.0
              }
            },
            capital: {
              capital_items: {
                liquid: [
                  {
                    description: 'Current accounts',
                    value: 1.0
                  },
                  {
                    description: 'Savings accounts',
                    value: 1.0
                  },
                  {
                    description: 'Money not in a bank account',
                    value: 10.0
                  },
                  {
                    description: 'Online current accounts',
                    value: 0.0
                  },
                  {
                    description: 'Online savings accounts',
                    value: 0.0
                  }
                ],
                non_liquid: [{
                  description: 'Interest in a trust',
                  value: 12.0
                }],
                vehicles: [
                  {
                    value: 120.0,
                    loan_amount_outstanding: 12.0,
                    date_of_purchase: '2017-05-26',
                    in_regular_use: false,
                    included_in_assessment: true,
                    assessed_value: 120.0
                  }
                ],
                properties: {
                  main_home: {
                    value: 10.0,
                    outstanding_mortgage: 20.0,
                    percentage_owned: 10.0,
                    main_home: true,
                    shared_with_housing_assoc: true,
                    transaction_allowance: 0.3,
                    allowable_outstanding_mortgage: 20.0,
                    net_value: -10.3,
                    net_equity: -19.3,
                    main_home_equity_disregard: 100_000.0,
                    assessed_equity: 0.0
                  },
                  additional_properties: [
                    {
                      value: 0.0,
                      outstanding_mortgage: 0.0,
                      percentage_owned: 0.0,
                      main_home: false,
                      shared_with_housing_assoc: false,
                      transaction_allowance: 0.0,
                      allowable_outstanding_mortgage: 0.0,
                      net_value: 0.0,
                      net_equity: 0.0,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 0.0
                    }
                  ]
                }
              }
            },
            remarks: {}
          }
        }
      end

      def self.not_eligible
        not_eligible_result = eligible
        not_eligible_result[:result_summary][:overall_result][:result] = 'not_eligible'
        not_eligible_result[:result_summary][:overall_result][:proceeding_types].each do |pt|
          pt[:result] = 'not_eligible'
        end
        not_eligible_result
      end

      def self.with_capital_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = 'contribution_required'
        result[:result_summary][:capital][:capital_contribution] = 465.66
        result[:result_summary][:overall_result][:capital_contribution] = 465.66
        result
      end

      def self.with_income_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = 'contribution_required'
        result[:result_summary][:overall_result][:income_contribution] = 366.82
        result[:result_summary][:disposable_income][:income_contribution] = 366.82
        result
      end

      def self.with_capital_and_income_contributions_required # rubocop:disable Metrics/AbcSize
        result = eligible
        result[:result_summary][:overall_result][:result] = 'contribution_required'

        result[:result_summary][:overall_result][:income_contribution] = 366.82
        eligible[:result_summary][:disposable_income][:income_contribution] = 366.82

        result[:result_summary][:overall_result][:result] = 'contribution_required'
        new_capital_section = result[:result_summary][:capital]
        new_capital_section[:capital_contribution] = 465.66
        result[:result_summary][:capital] = new_capital_section
        result[:result_summary][:overall_result][:capital_contribution] = 465.66

        result
      end

      def self.no_additional_properties
        result = eligible
        result[:assessment][:capital][:capital_items][:properties][:additional_properties] = []
        result
      end

      def self.with_no_vehicles
        result = eligible
        result[:assessment][:capital][:capital_items][:vehicles] = []
        result
      end

      def self.with_mortgage_costs
        result = eligible
        result[:result_summary][:disposable_income][:gross_housing_costs] = 120.0
        result
      end

      def self.with_monthly_income_equivalents
        result = eligible
        other_income = result[:assessment][:gross_income][:other_income]
        monthly_equivalents = other_income[:monthly_equivalents][:all_sources]
        monthly_equivalents = monthly_equivalents.transform_values { |x| x + 10 }
        other_income[:monthly_equivalents][:all_sources] = monthly_equivalents
        result[:assessment][:gross_income][:other_income] = other_income

        result
      end

      def self.with_monthly_outgoing_equivalents
        result = eligible
        other_income = result[:assessment][:disposable_income]
        monthly_equivalents = other_income[:monthly_equivalents][:all_sources]
        monthly_equivalents = monthly_equivalents.transform_values { |x| x + 10 }
        other_income[:monthly_equivalents][:all_sources] = monthly_equivalents
        result[:assessment][:disposable_income] = other_income

        result
      end

      def self.no_capital
        result = eligible
        new_capital_section = result[:assessment][:capital]
        new_capital_section[:capital_items][:liquid] = []
        new_capital_section[:capital_items][:non_liquid] = []
        new_capital_section[:capital_items][:vehicles] = []
        new_capital_section[:capital_items][:properties][:main_home] = {}
        new_capital_section[:capital_items][:properties][:additional_properties] = {}

        new_capital_summary = result[:result_summary][:capital]
        new_capital_summary[:total_liquid] = 0.0
        new_capital_summary[:total_non_liquid] = 0.0
        new_capital_summary[:total_vehicle] = 0.0
        new_capital_summary[:total_property] = 0.0
        new_capital_summary[:total_capital] = 0.0

        result[:result_summary][:capital] = new_capital_summary
        result[:assessment][:capital] = new_capital_section
        result
      end

      def self.with_additional_properties
        result = eligible
        property = {
          value: 5781.91,
          outstanding_mortgage: 10_202.39,
          percentage_owned: 8.33,
          main_home: false,
          shared_with_housing_assoc: true,
          transaction_allowance: 113.46,
          allowable_outstanding_mortgage: 8202.00,
          net_value: -4533.94,
          net_equity: -8000.82,
          main_home_equity_disregard: '0.0',
          assessed_equity: 125.33
        }
        result[:assessment][:capital][:capital_items][:properties][:additional_properties] = [property]
        result
      end

      def self.with_total_property; end

      def self.with_maintenance_received
        result = eligible
        result[:result_summary][:disposable_income][:maintenance_allowance] = 150.0
        result
      end

      def self.with_student_finance_received
        result = eligible
        result[:assessment][:gross_income][:irregular_income][:monthly_equivalents][:student_loan] = 125.0
        result
      end

      def self.with_total_deductions
        result = eligible
        deductions = result[:assessment][:disposable_income][:deductions]
        deductions[:dependants_allowance] = 1200.0
        deductions[:disregarded_state_benefits] = 100.0
        result[:assessment][:disposable_income][:deductions] = deductions
        result
      end

      def self.with_total_gross_income
        result = eligible
        result[:result_summary][:gross_income][:total_gross_income] = 150.0

        result
      end

      def self.unknown
        result = eligible
        result[:assessment][:assessment_result] = 'unknown'
        result[:assessment][:capital][:assessment_result] = 'unknown'
        result[:assessment][:disposable_income][:assessment_result] = 'unknown'
        result
      end
    end
  end
end
