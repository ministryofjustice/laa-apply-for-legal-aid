FactoryBot.define do
  factory :cfe_result, class: CFE::Result do
    submission { create :cfe_submission }
    legal_aid_application { submission.legal_aid_application }
    result { CFEResults::MockResults.eligible.to_json }

    trait :not_eligible do
      result { CFEResults::MockResults.not_eligible.to_json }
    end

    trait :contribution_required do
      result { CFEResults::MockResults.contribution_required.to_json }
    end

    trait :no_additional_properties do
      result { CFEResults::MockResults.no_additional_properties.to_json }
    end

    trait :with_additional_properties do
      result { CFEResults::MockResults.with_additional_properties.to_json }
    end

    trait :with_maintenance_outgoings do
      result { CFEResults::MockResults.with_maintenance_outgoings.to_json }
    end
  end
end
