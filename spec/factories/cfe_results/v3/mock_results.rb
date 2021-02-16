module CFEResults
  module V3
    class MockResults # rubocop:disable Metrics/ClassLength
      def self.eligible # rubocop:disable Metrics/MethodLength
        {
          version: '3',
          timestamp: '2020-01-28T16:37:07.921+00:00',
          success: true,
          assessment: {
            id: '41188692-9fa1-488d-818f-67f8509ff21a',
            client_reference_id: 'CLIENT-REF-0007',
            submission_date: '2020-01-28',
            matter_proceeding_type: 'domestic_abuse',
            assessment_result: 'eligible',
            applicant: {
              date_of_birth: '1996-08-15',
              involvement_type: 'applicant',
              has_partner_opponent: false,
              receives_qualifying_benefit: false,
              self_employed: false
            },
            gross_income: {
              summary: {
                total_gross_income: '150.0',
                upper_threshold: '999999999999.0',
                assessment_result: 'eligible'
              },
              irregular_income: {
                monthly_equivalents: {
                  student_loan: '0.0'
                }
              },
              state_benefits: {
                monthly_equivalents: {
                  all_sources: '75.0',
                  cash_transactions: '25.0',
                  bank_transactions: [
                    {
                      name: 'manually_chosen',
                      monthly_value: '50.00',
                      excluded_from_income_assessment: false
                    }
                  ]
                }
              },
              other_income: {
                monthly_equivalents: {
                  bank_transactions: {
                    friends_or_family: '40.0',
                    maintenance_in: '40.0',
                    property_or_lodger: '350.0',
                    pension: '50.0'
                  },
                  cash_transactions: {
                    friends_or_family: '10.59',
                    maintenance_in: '14.17',
                    property_or_lodger: '100.0',
                    pension: '32.52'
                  },
                  all_sources: {
                    friends_or_family: '50.59',
                    maintenance_in: '54.17',
                    property_or_lodger: '450.0',
                    pension: '82.52'
                  }
                }
              }
            },
            disposable_income: {
              monthly_equivalents: {
                bank_transactions: {
                  child_care: '60.0',
                  rent_or_mortgage: '100.0',
                  maintenance_out: '40.0',
                  legal_aid: '350.0'
                },
                cash_transactions: {
                  child_care: '40.0',
                  rent_or_mortgage: '25.0',
                  maintenance_out: '10.0',
                  legal_aid: '50.0'
                },
                all_sources: {
                  child_care: '100.0',
                  rent_or_mortgage: '125.0',
                  maintenance_out: '50.0',
                  legal_aid: '400.0'
                }
              },
              childcare_allowance: '0.0',
              deductions: {
                dependants_allowance: '291.86',
                disregarded_state_benefits: '1500.0'
              },
              dependant_allowance: '0.0',
              maintenance_allowance: '0.0',
              gross_housing_costs: '125.0',
              housing_benefit: '0.0',
              net_housing_costs: '125.0',
              total_outgoings_and_allowances: '175.0',
              total_disposable_income: '0.0',
              lower_threshold: '315.0',
              upper_threshold: '999999999999.0',
              assessment_result: 'eligible',
              income_contribution: '0.0'
            },
            capital: {
              capital_items: {
                liquid: [
                  {
                    description: 'Ab quasi autem rerum.',
                    value: '6692.12'
                  }
                ],
                non_liquid: [
                  {
                    description: 'Omnis sit et corrupti.',
                    value: '3902.92'
                  }
                ],
                vehicles: [
                  {
                    value: '1784.61',
                    loan_amount_outstanding: '3225.77',
                    date_of_purchase: '2014-07-01',
                    in_regular_use: true,
                    included_in_assessment: false,
                    assessed_value: '0.0'
                  }
                ],
                properties: {
                  main_home: {
                    value: '5985.82',
                    'outstanding_ mortgage': '7201.44',
                    percentage_owned: '1.87',
                    main_home: true,
                    shared_with_housing_assoc: false,
                    transaction_allowance: '179.57',
                    allowable_outstanding_mortgage: '7201.44',
                    net_value: '-1395.19',
                    net_equity: '-26.09',
                    main_home_equity_disregard: '100000.0',
                    assessed_equity: '0.0'
                  },
                  additional_properties: [
                    {
                      value: '0.0',
                      outstanding_mortgage: '8202.39',
                      percentage_owned: '8.33',
                      main_home: false,
                      shared_with_housing_assoc: true,
                      transaction_allowance: '113.46',
                      allowable_outstanding_mortgage: '8202.39',
                      net_value: '-4533.94',
                      net_equity: '-8000.82',
                      main_home_equity_disregard: '0.0',
                      assessed_equity: '0.0'
                    }
                  ]
                }
              },
              total_liquid: '5649.13',
              total_non_liquid: '3902.92',
              total_vehicle: '0.0',
              total_property: '1134.0',
              total_mortgage_allowance: '100000.0',
              total_capital: '9552.05',
              pensioner_capital_disregard: '0.0',
              assessed_capital: '9552.05',
              lower_threshold: '3000.0',
              upper_threshold: '999999999999.0',
              assessment_result: 'eligible',
              capital_contribution: '0.0'
            },
            remarks: {
            }
          }
        }
      end

      def self.not_eligible
        not_eligible_result = eligible
        not_eligible_result[:assessment][:assessment_result] = 'not_eligible'
        not_eligible_result[:assessment][:disposable_income][:assessment_result] = 'not_eligible'
        not_eligible_result[:assessment][:capital][:assessment_result] = 'not_eligible'
        not_eligible_result
      end

      def self.with_capital_contribution_required
        result = eligible
        result[:assessment][:assessment_result] = 'contribution_required'
        new_capital_section = result[:assessment][:capital]
        new_capital_section[:capital_contribution] = '465.66'
        new_capital_section[:assessment_result] = 'contribution_required'
        result[:assessment][:capital] = new_capital_section
        result
      end

      def self.with_income_contribution_required
        result = eligible
        result[:assessment][:assessment_result] = 'contribution_required'
        new_disposable_income = eligible[:assessment][:disposable_income]
        new_disposable_income[:assessment_result] = 'contribution_required'
        new_disposable_income[:income_contribution] = 366.82
        result[:assessment][:disposable_income] = new_disposable_income
        result
      end

      def self.with_capital_and_income_contributions_required # rubocop:disable Metrics/AbcSize
        result = eligible
        result[:assessment][:assessment_result] = 'contribution_required'

        new_disposable_income = eligible[:assessment][:disposable_income]
        new_disposable_income[:assessment_result] = 'contribution_required'
        new_disposable_income[:income_contribution] = 366.82
        result[:assessment][:disposable_income] = new_disposable_income

        result[:assessment][:assessment_result] = 'contribution_required'
        new_capital_section = result[:assessment][:capital]
        new_capital_section[:capital_contribution] = '465.66'
        new_capital_section[:assessment_result] = 'contribution_required'
        result[:assessment][:capital] = new_capital_section

        result
      end

      def self.no_additional_properties
        result = eligible
        result[:assessment][:capital][:capital_items][:properties][:additional_properties] = []
        result
      end

      def self.no_vehicles
        result = eligible
        result[:assessment][:capital][:capital_items][:vehicles] = []
        result
      end

      def self.with_no_mortgage_costs
        result = eligible
        result[:assessment][:disposable_income][:gross_housing_costs] = 0.0
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
        new_capital_section[:total_liquid] = '0.0'
        new_capital_section[:total_non_liquid] = '0.0'
        new_capital_section[:total_vehicle] = '0.0'
        new_capital_section[:total_property] = '0.0'
        new_capital_section[:total_capital] = '0.0'
        result[:assessment][:capital] = new_capital_section
        result
      end

      def self.with_additional_properties
        result = eligible
        property = {
          value: '5781.91',
          outstanding_mortgage: '10202.39',
          percentage_owned: '8.33',
          main_home: false,
          shared_with_housing_assoc: true,
          transaction_allowance: '113.46',
          allowable_outstanding_mortgage: '8202.00',
          net_value: '-4533.94',
          net_equity: '-8000.82',
          main_home_equity_disregard: '0.0',
          assessed_equity: '125.33'
        }
        result[:assessment][:capital][:capital_items][:properties][:additional_properties] = [property]
        result
      end

      def self.with_maintenance_received
        result = eligible
        result[:assessment][:disposable_income][:maintenance_allowance] = '150.00'
        result
      end

      def self.with_student_finance_received
        result = eligible
        result[:assessment][:gross_income][:irregular_income][:monthly_equivalents][:student_loan] = '125.00'
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
