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
                benefits_in_kind: 16.60,
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
                  legal_aid: 100.0,
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

      # This result has has been faked, to cover an example where CFE returns 'ineligible'
      # for more than one proceeding category, which is currently not possible.
      # Currently, for example, if an applicant is ineligible for disposable income and capital,
      # CFE returns the disposable income result for proceedings as 'ineligible',
      # but the capital result for proceedings as 'pending'.
      # Have added this mock result as there is code to cover the scenario where CFE returns
      # an ineligible result for more than one category e.g. disposable income and capital
      # even though it his is not currently not happening as there is a CFE ticket to introduce
      # this functionality. See https://dsdmoj.atlassian.net/browse/LEP-349
      def self.fake_ineligible_disposable_income_and_capital
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

      def self.not_eligible
        not_eligible_result = eligible
        not_eligible_result[:result_summary][:overall_result][:result] = "ineligible"
        not_eligible_result[:result_summary][:overall_result][:proceeding_types].each do |pt|
          pt[:result] = "not_eligible"
        end
        not_eligible_result
      end

      def self.with_capital_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = "contribution_required"
        result[:result_summary][:capital][:capital_contribution] = 465.66
        result[:result_summary][:overall_result][:capital_contribution] = 465.66
        result
      end

      def self.partially_eligible_with_income_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = "partially_eligible"
        result[:result_summary][:disposable_income][:income_contribution] = 238.56
        result[:result_summary][:overall_result][:income_contribution] = 238.56
        result
      end

      def self.partially_eligible_with_capital_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = "partially_eligible"
        result[:result_summary][:capital][:capital_contribution] = 468.56
        result[:result_summary][:overall_result][:capital_contribution] = 468.56
        result
      end

      def self.with_income_contribution_required
        result = eligible
        result[:result_summary][:overall_result][:result] = "contribution_required"
        result[:result_summary][:overall_result][:income_contribution] = 366.82
        result[:result_summary][:disposable_income][:income_contribution] = 366.82
        result
      end

      def self.with_capital_and_income_contributions_required
        result = eligible
        result[:result_summary][:overall_result][:result] = "contribution_required"

        result[:result_summary][:overall_result][:income_contribution] = 366.82
        eligible[:result_summary][:disposable_income][:income_contribution] = 366.82

        result[:result_summary][:overall_result][:result] = "contribution_required"
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
        result[:result_summary][:disposable_income][:net_housing_costs] += 10.0

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
          main_home_equity_disregard: "0.0",
          assessed_equity: 125.33,
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
        result[:assessment][:assessment_result] = "unknown"
        result[:assessment][:capital][:assessment_result] = "unknown"
        result[:assessment][:disposable_income][:assessment_result] = "unknown"
        result
      end

      def self.mixed_proceeding_type_results
        result = eligible
        result[:result_summary][:overall_result][:proceeding_types] = [
          {
            ccms_code: "DA006",
            result: "eligible",
          },
          {
            ccms_code: "SE013",
            result: "ineligible",
          },
          {
            ccms_code: "SE014",
            result: "partially_eligible",
          },
        ]
        result
      end

      def self.partially_eligible
        result = eligible
        result[:result_summary][:overall_result][:matter_types] << { matter_type: "section8", result: "ineligible" }
        result[:result_summary][:overall_result][:proceeding_types] << { ccms_code: "SE003", result: "ineligible" }
        result[:result_summary][:gross_income][:proceeding_types] << { ccms_code: "SE003", upper_threshold: 2657.0, result: "eligible" }
        result[:result_summary][:disposable_income][:proceeding_types] << { ccms_code: "SE003", upper_threshold: 733.0, lower_threshold: 315.0, result: "ineligible" }
        result
      end

      def self.with_employments
        result = eligible
        employment_income = {
          gross_income: 1041.00,
          benefits_in_kind: 16.60,
          tax: -104.10,
          national_insurance: -18.66,
          fixed_employment_deduction: -45.00,
          net_employment_income: 8898.84,
        }
        jobs = [
          {
            name: "Job 1",
            payments: [
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
            ],
          },
          {
            name: "Job 2",
            payments: [
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
              {
                date: "2021-10-30",
                gross: 1046.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                net_employment_income: 8898.84,
              },
            ],
          },
        ]
        result[:result_summary][:disposable_income][:employment_income] = employment_income
        result[:assessment][:gross_income][:employment_income] = jobs
        result
      end

      def self.with_employment_remarks(record)
        laa = record.legal_aid_application
        employments = laa.employments.order(:name)
        payments = employments.first.employment_payments
        refunded_nic_ids = payments.select { |p| p.national_insurance > 0 }.map(&:id)
        refunded_tax_ids = payments.select { |p| p.tax > 0 }.map(&:id)
        result = with_employments
        remarks = {
          employment: {
            multiple_employments: [employments.map(&:id)],
          },
          employment_gross_income: {
            amount_variation: [payments.map(&:id)],
            unknown_frequency: [payments.map(&:id)],
          },
          employment_nic: {
            amount_variation: [payments.map(&:id)],
            refunds: refunded_nic_ids,
          },
          employment_tax: {
            amount_variation: [payments.map(&:id)],
            refunds: refunded_tax_ids,
          },
        }
        result[:assessment][:remarks] = remarks
        result
      end

      def self.with_no_employments
        result = eligible
        result[:result_summary][:disposable_income][:employment_income] = {}
        result[:assessment][:gross_income][:employment_income] = []
        result
      end

      def self.with_partner
        result = eligible
        partner_gross_income = {
          employment_income: [
            {
              name: "Job 1",
              payments: [
                {
                  date: "2023-11-15",
                  gross: 2083.33,
                  benefits_in_kind: 0.0,
                  tax: -206.0,
                  national_insurance: -154.36,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 1722.97,
                },
                {
                  date: "2023-10-14",
                  gross: 3083.33,
                  benefits_in_kind: 0.0,
                  tax: -406.0,
                  national_insurance: -274.36,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 2402.97,
                },
              ],
            },
          ],
          irregular_income: {
            monthly_equivalents: {
              student_loan: 100.0,
              unspecified_source: 0.0,
            },
          },
          state_benefits: {
            monthly_equivalents: {
              all_sources: 86.67,
              cash_transactions: 0.0,
              bank_transactions: [],
            },
          },
          other_income: {
            monthly_equivalents: {
              all_sources: {
                friends_or_family: 166.67,
                maintenance_in: 21.0,
                property_or_lodger: 200.0,
                pension: 30.0,
              },
              bank_transactions: {
                friends_or_family: 0,
                maintenance_in: 0,
                property_or_lodger: 0,
                pension: 0,
              },
              cash_transactions: {
                friends_or_family: 0.0,
                maintenance_in: 0.0,
                property_or_lodger: 0.0,
                pension: 0.0,
              },
            },
          },
        }
        partner_disposable_income = {
          monthly_equivalents: {
            all_sources: {
              child_care: 30.0,
              rent_or_mortgage: 400.0,
              maintenance_out: 50.0,
              legal_aid: 0.0,
              pension_contribution: 0.0,
            },
            bank_transactions: {
              child_care: 0.0,
              rent_or_mortgage: 0.0,
              maintenance_out: 0.0,
              legal_aid: 0.0,
              pension_contribution: 0.0,
            },
            cash_transactions: {
              child_care: 0.0,
              rent_or_mortgage: 0.0,
              maintenance_out: 0.0,
              legal_aid: 0.0,
              pension_contribution: 0.0,
            },
          },
          childcare_allowance: 0.0,
          deductions: {
            dependants_allowance: 0.0,
            disregarded_state_benefits: 0.0,
          },
        }
        partner_capital = {
          capital_items: {
            liquid: [
              { description: "Partner current accounts", value: 400.0 },
              { description: "Partner savings accounts", value: 300.0 },
              { description: "Joint current accounts", value: 200.0 },
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
                transaction_allowance: 0,
                allowable_outstanding_mortgage: 0.0,
                net_value: 0,
                net_equity: 0,
                smod_allowance: 0,
                main_home_equity_disregard: 0,
                assessed_equity: 0,
                subject_matter_of_dispute: false,
              },
              additional_properties: [],
            },
          },
        }
        partner_disposable_income_summary = {
          dependant_allowance_under_16: 0,
          dependant_allowance_over_16: 0,
          dependant_allowance: 0,
          gross_housing_costs: 0.0,
          housing_benefit: 0.0,
          net_housing_costs: 400.0,
          maintenance_allowance: 0.0,
          total_outgoings_and_allowances: 1052.06,
          total_disposable_income: 2577.11,
          employment_income: {
            gross_income: 2229.17,
            benefits_in_kind: 0.0,
            tax: -235.2,
            national_insurance: -171.86,
            prisoner_levy: 0.0,
            student_debt_repayment: 0.0,
            fixed_employment_deduction: -45.0,
            net_employment_income: 1777.11,
          },
        }
        partner_capital_summary = {
          pensioner_disregard_applied: 0.0,
          total_liquid: 500.0,
          total_non_liquid: 0.0,
          total_vehicle: 0.0,
          total_property: 0.0,
          total_mortgage_allowance: 999_999_999_999.0,
          total_capital: 500.0,
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
        result[:assessment][:partner_gross_income] = partner_gross_income
        result[:assessment][:partner_disposable_income] = partner_disposable_income
        result[:assessment][:partner_capital] = partner_capital
        result[:result_summary][:partner_gross_income] = { total_gross_income: 150.0 }
        result[:result_summary][:partner_capital] = partner_capital_summary
        result[:result_summary][:partner_disposable_income] = partner_disposable_income_summary
        result[:result_summary][:disposable_income][:partner_allowance] = 211.32
        result
      end

      # NOTE: this is a fake setup to exercise a CFE result with remarks that result in "all" review reasons
      # Amend to add any new remarks as necessary.
      def self.with_all_remarks
        result = with_partner

        # mark with all known client and partner remarks that can be returned by CFE so we can display their
        # case worker review reasons.
        remarks = {
          client_employment: {
            multiple_employments: [],
          },
          client_employment_gross_income: {
            amount_variation: [],
            unknown_frequency: [],
          },
          client_employment_nic: {
            amount_variation: [],
            refunds: [],
          },
          client_employment_tax: {
            amount_variation: [],
            refunds: [],
          },
          client_state_benefit_payment: {
            amount_variation: [],
            unknown_frequency: [],
          },
          client_current_account_balance: {
            residual_balance: [],
          },
          partner_employment: {
            multiple_employments: [],
          },
          partner_employment_gross_income: {
            amount_variation: [],
            unknown_frequency: [],
          },
          partner_employment_nic: {
            amount_variation: [],
            refunds: [],
          },
          partner_employment_tax: {
            amount_variation: [],
            refunds: [],
          },
          partner_state_benefit_payment: {
            amount_variation: [],
            unknown_frequency: [],
          },
          partner_current_account_balance: {
            residual_balance: [],
          },
        }
        result[:assessment][:remarks] = remarks

        result[:result_summary][:overall_result][:result] = "ineligible"
        result[:result_summary][:overall_result][:proceeding_types].each do |pt|
          pt[:result] = "not_eligible"
        end
        result
      end

      def self.without_partner_jobs
        result = with_partner
        result[:assessment][:partner_gross_income][:employment_income] = []
        result
      end
    end
  end
end
