module CFEResults
  module V4
    FactoryBot.define do
      factory :cfe_v4_result, class: CFE::V4::Result do
        submission { create :cfe_submission }
        legal_aid_application { submission.legal_aid_application }
        result { CFEResults::V4::MockResults.eligible.to_json }
        type { 'CFE::V4::Result' }

        trait :eligible do
          result { CFEResults::V4::MockResults.eligible.to_json }
        end

        trait :not_eligible do
          result { CFEResults::V4::MockResults.not_eligible.to_json }
        end

        trait :no_capital do
          result { CFEResults::V4::MockResults.no_capital.to_json }
        end

        trait :with_capital_contribution_required do
          result { CFEResults::V4::MockResults.with_capital_contribution_required.to_json }
        end

        trait :with_income_contribution_required do
          result { CFEResults::V4::MockResults.with_income_contribution_required.to_json }
        end

        trait :with_capital_and_income_contributions_required do
          result { CFEResults::V4::MockResults.with_capital_and_income_contributions_required.to_json }
        end

        trait :no_additional_properties do
          result { CFEResults::V4::MockResults.no_additional_properties.to_json }
        end

        trait :with_additional_properties do
          result { CFEResults::V4::MockResults.with_additional_properties.to_json }
        end

        trait :with_no_vehicles do
          result { CFEResults::V4::MockResults.with_no_vehicles.to_json }
        end

        trait :with_maintenance_received do
          result { CFEResults::V4::MockResults.with_maintenance_received.to_json }
        end

        trait :with_student_finance_received do
          result { CFEResults::V4::MockResults.with_student_finance_received.to_json }
        end

        trait :with_mortgage_costs do
          result { CFEResults::V4::MockResults.with_mortgage_costs.to_json }
        end

        trait :with_monthly_income_equivalents do
          result { CFEResults::V4::MockResults.with_monthly_income_equivalents.to_json }
        end

        trait :with_monthly_outgoing_equivalents do
          result { CFEResults::V4::MockResults.with_monthly_outgoing_equivalents.to_json }
        end

        trait :with_total_gross_income do
          result { CFEResults::V4::MockResults.with_total_gross_income.to_json }
        end

        trait :with_total_deductions do
          result { CFEResults::V4::MockResults.with_total_deductions.to_json }
        end

        trait :with_unknown_result do
          result { CFEResults::V4::MockResults.unknown.to_json }
        end
      end
    end
  end
end
