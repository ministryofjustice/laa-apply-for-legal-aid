FactoryBot.define do
  factory :cfe_v1_result, class: "CFE::V1::Result" do
    submission factory: :cfe_submission
    legal_aid_application { submission.legal_aid_application }
    result { CFEResults::V1::MockResults.eligible.to_json }

    trait :eligible do
      result { CFEResults::V1::MockResults.eligible.to_json }
    end

    trait :not_eligible do
      result { CFEResults::V1::MockResults.not_eligible.to_json }
    end

    trait :contribution_required do
      result { CFEResults::V1::MockResults.contribution_required.to_json }
    end

    trait :no_capital do
      result { CFEResults::V1::MockResults.no_capital.to_json }
    end

    trait :no_additional_properties do
      result { CFEResults::V1::MockResults.no_additional_properties.to_json }
    end

    trait :with_additional_properties do
      result { CFEResults::V1::MockResults.with_additional_properties.to_json }
    end
  end

  factory :cfe_v2_result, class: "CFE::V2::Result" do
    submission factory: :cfe_submission
    legal_aid_application { submission.legal_aid_application }
    result { CFEResults::V2::MockResults.eligible.to_json }

    trait :eligible do
      result { CFEResults::V2::MockResults.eligible.to_json }
    end

    trait :not_eligible do
      result { CFEResults::V2::MockResults.not_eligible.to_json }
    end

    trait :no_capital do
      result { CFEResults::V2::MockResults.no_capital.to_json }
    end

    trait :with_capital_contribution_required do
      result { CFEResults::V2::MockResults.with_capital_contribution_required.to_json }
    end

    trait :with_income_contribution_required do
      result { CFEResults::V2::MockResults.with_income_contribution_required.to_json }
    end

    trait :with_capital_and_income_contributions_required do
      result { CFEResults::V2::MockResults.with_capital_and_income_contributions_required.to_json }
    end

    trait :no_additional_properties do
      result { CFEResults::V2::MockResults.no_additional_properties.to_json }
    end

    trait :with_additional_properties do
      result { CFEResults::V2::MockResults.with_additional_properties.to_json }
    end

    trait :no_vehicles do
      result { CFEResults::V2::MockResults.no_vehicles.to_json }
    end

    trait :with_maintenance_received do
      result { CFEResults::V2::MockResults.with_maintenance_received.to_json }
    end

    trait :with_student_finance_received do
      result { CFEResults::V2::MockResults.with_student_finance_received.to_json }
    end

    trait :with_no_mortgage_costs do
      result { CFEResults::V2::MockResults.with_no_mortgage_costs.to_json }
    end

    trait :with_unknown_result do
      result { CFEResults::V2::MockResults.unknown.to_json }
    end
  end
end
