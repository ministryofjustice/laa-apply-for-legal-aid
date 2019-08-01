FactoryBot.define do
  factory :proceeding_type_scope_limitation do
    proceeding_type { create :proceeding_type }
    scope_limitation { create :scope_limitation }

    trait :substantive_default do
      substantive_default { true }
      delegated_functions_default { false }
    end

    trait :delegated_functions_default do
      substantive_default { false }
      delegated_functions_default { true }
    end
  end
end
