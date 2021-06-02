module CFEResults
  module V3
    FactoryBot.define do
      factory :cfe_v3_result, class: CFE::V3::Result do
        submission { create :cfe_submission }
        legal_aid_application { submission.legal_aid_application }
        result { CFEResults::V3::MockResults.eligible.to_json }
        type { 'CFE::V3::Result' }

        trait :eligible do
          result { CFEResults::V3::MockResults.eligible.to_json }
        end

        trait :not_eligible do
          result { CFEResults::V3::MockResults.not_eligible.to_json }
        end

        trait :no_capital do
          result { CFEResults::V3::MockResults.no_capital.to_json }
        end

        trait :with_capital_contribution_required do
          result { CFEResults::V3::MockResults.with_capital_contribution_required.to_json }
        end

        trait :with_income_contribution_required do
          result { CFEResults::V3::MockResults.with_income_contribution_required.to_json }
        end

        trait :with_capital_and_income_contributions_required do
          result { CFEResults::V3::MockResults.with_capital_and_income_contributions_required.to_json }
        end

        trait :no_additional_properties do
          result { CFEResults::V3::MockResults.no_additional_properties.to_json }
        end

        trait :with_additional_properties do
          result { CFEResults::V3::MockResults.with_additional_properties.to_json }
        end

        trait :no_vehicles do
          result { CFEResults::V3::MockResults.no_vehicles.to_json }
        end

        trait :with_maintenance_received do
          result { CFEResults::V3::MockResults.with_maintenance_received.to_json }
        end

        trait :with_student_finance_received do
          result { CFEResults::V3::MockResults.with_student_finance_received.to_json }
        end

        trait :with_no_mortgage_costs do
          result { CFEResults::V3::MockResults.with_no_mortgage_costs.to_json }
        end

        trait :with_unknown_result do
          result { CFEResults::V3::MockResults.unknown.to_json }
        end
      end
    end
  end
end
