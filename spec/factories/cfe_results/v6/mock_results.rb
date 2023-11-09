module CFEResults
  module V6
    class MockResults
      def self.eligible
        {
          version: "6",
          timestamp: "2021-05-26T12:51:56.329Z",
          success: true,
          result_summary: {
            overall_result: {
              result: "eligible",
              capital_contribution: 0.0,
              income_contribution: 0.0,
              matter_types: [{
                matter_type: "domestic_abuse",
                result: "eligible",
              }],
              proceeding_types: [
                {
                  ccms_code: "DA006",
                  result: "eligible",
                },
                {
                  ccms_code: "DA002",
                  result: "eligible",
                },
              ],
            },
            gross_income: {
              total_gross_income: 0.0,
              proceeding_types: [
                {
                  ccms_code: "DA006",
                  upper_threshold: 999_999_999_999.0,
                  result: "pending",
                },
                {
                  ccms_code: "DA002",
                  upper_threshold: 999_999_999_999.0,
                  result: "pending",
                },
              ],
            },
            disposable_income: {
              dependant_allowance: 0.0,
              gross_housing_costs: 0.0,
              housing_benefit: 0.0,
              net_housing_costs: 125.0,
              maintenance_allowance: 0.0,
              total_outgoings_and_allowances: 0.0,
              total_disposable_income: 0.0,
              income_contribution: 0.0,
              employment_income: {
                gross_income: 2143.97,
                benefits_in_kind: 0.0,
                tax: -204.15,
                national_insurance: -161.64,
                fixed_employment_deduction: -45.0,
                net_employment_income: 1778.18,
              },
              proceeding_types: [
                {
                  ccms_code: "DA006",
                  upper_threshold: 999_999_999_999.0,
                  lower_threshold: 315.0,
                  result: "pending",
                },
                {
                  ccms_code: "DA002",
                  upper_threshold: 999_999_999_999.0,
                  lower_threshold: 315.0,
                  result: "pending",
                },
              ],
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
                  ccms_code: "DA006",
                  lower_threshold: 3000.0,
                  upper_threshold: 999_999_999_999.0,
                  result: "eligible",
                },
                {
                  ccms_code: "DA002",
                  lower_threshold: 3000.0,
                  upper_threshold: 999_999_999_999.0,
                  result: "eligible",
                },
              ],
            },
          },
          assessment: {
            id: "b60d9312-b77b-4c5f-aa79-ba8508800c59",
            client_reference_id: "L-C36-J5T",
            submission_date: "2021-05-26",
            applicant: {
              date_of_birth: "1980-01-10",
              involvement_type: "applicant",
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
              self_employed: false,
            },
            gross_income: {
              irregular_income: {
                monthly_equivalents: {
                  student_loan: 0.0,
                },
              },
              state_benefits: {
                monthly_equivalents: {
                  all_sources: 75.0,
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
                  rent_or_mortgage: 125.0,
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
                    description: "Current accounts",
                    value: 1.0,
                  },
                  {
                    description: "Savings accounts",
                    value: 1.0,
                  },
                  {
                    description: "Money not in a bank account",
                    value: 10.0,
                  },
                  {
                    description: "Online current accounts",
                    value: 0.0,
                  },
                  {
                    description: "Online savings accounts",
                    value: 0.0,
                  },
                ],
                non_liquid: [{
                  description: "Interest in a trust",
                  value: 12.0,
                }],
                vehicles: [
                  {
                    value: 120.0,
                    loan_amount_outstanding: 12.0,
                    date_of_purchase: "2017-05-26",
                    in_regular_use: false,
                    included_in_assessment: true,
                    assessed_value: 120.0,
                  },
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

      def self.ineligible_gross_income
        result = eligible
        result[:result_summary][:overall_result][:result] = "ineligible"
        result[:result_summary][:gross_income] = {
          total_gross_income: 43_333.33,
          proceeding_types: [
            {
              ccms_code: "SE097A",
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
              result: "ineligible",
              client_involvement_type: "A",
            },
            {
              ccms_code: "SE101E",
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
              result: "ineligible",
              client_involvement_type: "A",
            },
          ],
          combined_total_gross_income: 43_333.33,
        }
        result[:result_summary][:disposable_income] = {
          dependant_allowance_under_16: 0,
          dependant_allowance_over_16: 0,
          dependant_allowance: 0,
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
            prisoner_levy: 0.0,
            student_debt_repayment: 0.0,
            fixed_employment_deduction: 0.0,
            net_employment_income: 0.0,
          },
          proceeding_types: [
            {
              ccms_code: "SE097A",
              upper_threshold: 733.0,
              lower_threshold: 315.0,
              result: "pending",
              client_involvement_type: "A",
            },
            {
              ccms_code: "SE101E",
              upper_threshold: 733.0,
              lower_threshold: 315.0,
              result: "pending",
              client_involvement_type: "A",
            },
          ],
          combined_total_disposable_income: 0.0,
          combined_total_outgoings_and_allowances: 0.0,
          partner_allowance: 0,
          lone_parent_allowance: 0,
          income_contribution: 0,
        }
        result[:result_summary][:capital] = {
          pensioner_disregard_applied: 0.0,
          total_liquid: 0.0,
          total_non_liquid: 0.0,
          total_vehicle: 0.0,
          total_property: 0.0,
          total_mortgage_allowance: 0.0,
          total_capital: 0.0,
          subject_matter_of_dispute_disregard: 0.0,
          assessed_capital: 0.0,
          total_capital_with_smod: 0,
          disputed_non_property_disregard: 0,
          proceeding_types: [
            {
              ccms_code: "SE097A",
              upper_threshold: 8000.0,
              lower_threshold: 3000.0,
              result: "pending",
              client_involvement_type: "A",
            },
            {
              ccms_code: "SE101E",
              upper_threshold: 8000.0,
              lower_threshold: 3000.0,
              result: "pending",
              client_involvement_type: "A",
            },
          ],
          combined_disputed_capital: 0,
          combined_non_disputed_capital: 0,
          capital_contribution: 0.0,
          pensioner_capital_disregard: 0.0,
          combined_assessed_capital: 0.0,
        }
        result
      end

      def self.ineligible_capital
        result = eligible
        result[:result_summary][:overall_result][:result] = "ineligible"
        result[:result_summary][:gross_income] = {
          total_gross_income: 0.0,
          proceeding_types: [
            { ccms_code: "SE097A",
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
              result: "eligible",
              client_involvement_type: "A" },
            { ccms_code: "SE101E",
              upper_threshold: 2657.0,
              lower_threshold: 0.0,
              result: "eligible",
              client_involvement_type: "A" },
          ],
          combined_total_gross_income: 0.0,
        }
        result[:result_summary][:disposable_income] = {
          dependant_allowance_under_16: 0,
          dependant_allowance_over_16: 0,
          dependant_allowance: 0,
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
            prisoner_levy: 0.0,
            student_debt_repayment: 0.0,
            fixed_employment_deduction: 0.0,
            net_employment_income: 0.0,
          },
          proceeding_types: [
            { ccms_code: "SE097A",
              upper_threshold: 733.0,
              lower_threshold: 315.0,
              result: "eligible",
              client_involvement_type: "A" },
            { ccms_code: "SE101E",
              upper_threshold: 733.0,
              lower_threshold: 315.0,
              result: "eligible",
              client_involvement_type: "A" },
          ],
          combined_total_disposable_income: 0.0,
          combined_total_outgoings_and_allowances: 0.0,
          partner_allowance: 0,
          lone_parent_allowance: 0,
          income_contribution: 0.0,
        }
        result[:result_summary][:capital] = {
          pensioner_disregard_applied: 0.0,
          total_liquid: 500_000.0,
          total_non_liquid: 0.0,
          total_vehicle: 0.0,
          total_property: 0.0,
          total_mortgage_allowance: 999_999_999_999.0,
          total_capital: 500_000.0,
          subject_matter_of_dispute_disregard: 0.0,
          assessed_capital: 500_000.0,
          total_capital_with_smod: 500_000.0,
          disputed_non_property_disregard: 0,
          proceeding_types: [
            { ccms_code: "SE097A",
              upper_threshold: 8000.0,
              lower_threshold: 3000.0,
              result: "ineligible",
              client_involvement_type: "A" },
            { ccms_code: "SE101E",
              upper_threshold: 8000.0,
              lower_threshold: 3000.0,
              result: "ineligible",
              client_involvement_type: "A" },
          ],
          combined_disputed_capital: 0,
          combined_non_disputed_capital: 500_000.0,
          capital_contribution: 497_000.0,
          pensioner_capital_disregard: 0.0,
          combined_assessed_capital: 500_000.0,
        }
        result
      end

      def self.ineligible_disposable_income
        result = eligible
        result[:result_summary][:overall_result][:result] = "ineligible"
        result[:result_summary][:gross_income] = {
          total_gross_income: 1000.0,
          proceeding_types: [{ ccms_code: "SE100E",
                               upper_threshold: 2657.0,
                               lower_threshold: 0.0,
                               result: "eligible",
                               client_involvement_type: "A" },
                             { ccms_code: "SE101E",
                               upper_threshold: 2657.0,
                               lower_threshold: 0.0,
                               result: "eligible",
                               client_involvement_type: "A" }],
          combined_total_gross_income: 1000.0,
        }
        result[:result_summary][:disposable_income] = {
          dependant_allowance_under_16: 0,
          dependant_allowance_over_16: 0,
          dependant_allowance: 0,
          gross_housing_costs: 0.0,
          housing_benefit: 0.0,
          net_housing_costs: 0.0,
          maintenance_allowance: 0.0,
          total_outgoings_and_allowances: 0.0,
          total_disposable_income: 1000.0,
          employment_income: { gross_income: 0.0,
                               benefits_in_kind: 0.0,
                               tax: 0.0,
                               national_insurance: 0.0,
                               prisoner_levy: 0.0,
                               student_debt_repayment: 0.0,
                               fixed_employment_deduction: 0.0,
                               net_employment_income: 0.0 },
          proceeding_types: [{ ccms_code: "SE100E",
                               upper_threshold: 733.0,
                               lower_threshold: 315.0,
                               result: "ineligible",
                               client_involvement_type: "A" },
                             { ccms_code: "SE101E",
                               upper_threshold: 733.0,
                               lower_threshold: 315.0,
                               result: "ineligible",
                               client_involvement_type: "A" }],
          combined_total_disposable_income: 1000.0,
          combined_total_outgoings_and_allowances: 0.0,
          partner_allowance: 0,
          lone_parent_allowance: 0,
          income_contribution: 0.0,
        }
        result[:result_summary][:capital] = {
          pensioner_disregard_applied: 0.0,
          total_liquid: 0.0,
          total_non_liquid: 0.0,
          total_vehicle: 0.0,
          total_property: 0.0,
          total_mortgage_allowance: 0.0,
          total_capital: 0.0,
          subject_matter_of_dispute_disregard: 0.0,
          assessed_capital: 0.0,
          total_capital_with_smod: 0,
          disputed_non_property_disregard: 0,
          proceeding_types: [{ ccms_code: "SE100E",
                               upper_threshold: 8000.0,
                               lower_threshold: 3000.0,
                               result: "pending",
                               client_involvement_type: "A" },
                             { ccms_code: "SE101E",
                               upper_threshold: 8000.0,
                               lower_threshold: 3000.0,
                               result: "pending",
                               client_involvement_type: "A" }],
          combined_disputed_capital: 0,
          combined_non_disputed_capital: 0,
          capital_contribution: 0.0,
          pensioner_capital_disregard: 0.0,
          combined_assessed_capital: 0.0,
        }
        result
      end
    end
  end
end
