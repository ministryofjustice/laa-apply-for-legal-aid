module CFE
  module Empty
    class EmptyResult
      def self.blank_cfe_result
        {
          version: "Empty",
          timestamp: Time.zone.now.iso8601,
          success: true,
          result_summary: {
            overall_result: {
              result: "no_assessment",
              capital_contribution: 0.0,
              income_contribution: 0.0,
              matter_types: [
                {
                  matter_type: "domestic abuse (DA)",
                  result: "no_assessment",
                },
              ],
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  result: "no_assessment",
                },
              ],
            },
            gross_income: {
              total_gross_income: 0.0,
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  upper_threshold: 999_999_999_999.0,
                  result: "no_assessment",
                },
              ],
            },
            disposable_income: {
              dependant_allowance: 0.0,
              gross_housing_costs: 0.0,
              housing_benefit: 0.0,
              net_housing_costs: 0.0,
              maintenance_allowance: 0.0,
              total_outgoings_and_allowances: 0.0,
              total_disposable_income: 0.0,
              employment_income: {
                gross_income: 0.0,
                benefits_in_kind: 0.0,
                tax: 0.0,
                national_insurance: 0.0,
                fixed_employment_deduction: -45.0,
                net_employment_income: 0.0,
              },
              income_contribution: 0.0,
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  upper_threshold: 999_999_999_999.0,
                  lower_threshold: 315.0,
                  result: "no_assessment",
                },
              ],
            },
            capital: {
              total_liquid: 0.0,
              total_non_liquid: 0.0,
              total_vehicle: 0.0,
              total_property: 0.0,
              total_mortgage_allowance: 999_999_999_999.0,
              total_capital: 0.0,
              pensioner_capital_disregard: 0.0,
              capital_contribution: 0.0,
              assessed_capital: 0.0,
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  lower_threshold: 3000.0,
                  upper_threshold: 999_999_999_999.0,
                  result: "no_assessment",
                },
              ],
            },
          },
          assessment: {
            id: "11111111-2222-3333-4444-555555555555",
            client_reference_id: "L-XXX-XXX",
            submission_date: Time.zone.today,
            applicant: {
              date_of_birth: "1900-01-01",
              involvement_type: "applicant",
              has_partner_opponent: false,
              receives_qualifying_benefit: false,
              self_employed: false,
            },
            gross_income: {
              employment_income: [],
              irregular_income: {
                monthly_equivalents: {
                  student_loan: 0.0,
                },
              },
              state_benefits: {
                monthly_equivalents: {
                  all_sources: 0.0,
                  cash_transactions: 0.0,
                  bank_transactions: [],
                },
              },
              other_income: {
                monthly_equivalents: {
                  all_sources: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0,
                  },
                  bank_transactions: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0,
                  },
                  cash_transactions: {
                    friends_or_family: 0.0,
                    maintenance_in: 0.0,
                    property_or_lodger: 0.0,
                    pension: 0.0,
                  },
                },
              },
            },
            disposable_income: {
              monthly_equivalents: {
                all_sources: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0,
                },
                bank_transactions: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0,
                },
                cash_transactions: {
                  child_care: 0.0,
                  rent_or_mortgage: 0.0,
                  maintenance_out: 0.0,
                  legal_aid: 0.0,
                },
              },
              childcare_allowance: 0.0,
              deductions: {
                dependants_allowance: 0.0,
                disregarded_state_benefits: 0.0,
              },
            },
            capital: {
              capital_items: {
                liquid: [
                  {
                    description: "Online current accounts",
                    value: 0.0,
                  },
                  {
                    description: "Online savings accounts",
                    value: 0.0,
                  },
                ],
                non_liquid: [],
                vehicles: [],
                properties: {
                  main_home: {
                    value: 0.0,
                    outstanding_mortgage: 0.0,
                    percentage_owned: 0.0,
                    main_home: true,
                    shared_with_housing_assoc: false,
                    transaction_allowance: 0.0,
                    allowable_outstanding_mortgage: 0.0,
                    net_value: 0.0,
                    net_equity: 0.0,
                    main_home_equity_disregard: 100_000.0,
                    assessed_equity: 0.0,
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
                      assessed_equity: 0.0,
                    },
                  ],
                },
              },
            },
            remarks: {},
          },
        }
      end
    end
  end
end
