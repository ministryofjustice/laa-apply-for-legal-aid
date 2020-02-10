FactoryBot.define do
  factory :cfe_v1_result, class: CFE::V1::Result do
    submission { create :cfe_submission }
    legal_aid_application { submission.legal_aid_application }
    result { CFEResults::V1::MockResults.eligible.to_json }

    trait :eligible do
      result { CFEResults::MockResults.eligible.to_json }
    end

    trait :not_eligible do
      result { CFEResults::V1::MockResults.not_eligible.to_json }
    end

    trait :contribution_required do
      result { CFEResults::V1::MockResults.contribution_required.to_json }
    end

    trait :no_additional_properties do
      result { CFEResults::V1::MockResults.no_additional_properties.to_json }
    end

    trait :with_additional_properties do
      result { CFEResults::V1::MockResults.with_additional_properties.to_json }
    end
  end

  factory :cfe_v2_result, class: CFE::V2::Result do
    submission { create :cfe_submission }
    legal_aid_application { submission.legal_aid_application }
    result { CFEResults::V2::MockResults.eligible.to_json }

    trait :not_eligible do
      result { CFEResults::V2::MockResults.not_eligible.to_json }
    end

    trait :contribution_required do
      result { CFEResults::V2::MockResults.contribution_required.to_json }
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

    trait :with_maintenance_outgoings do
      result { CFEResults::V2::MockResults.with_maintenance_outgoings.to_json }
    end

    trait :no_mortgage do
      result { CFEResults::V2::MockResults.no_mortgage.to_json }
    end
  end
end
