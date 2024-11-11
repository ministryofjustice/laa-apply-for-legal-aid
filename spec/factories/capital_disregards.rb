FactoryBot.define do
  factory :capital_disregard do
    legal_aid_application
    name { "backdated_benefits" }
    mandatory { true }

    trait :mandatory do
      mandatory { true }
    end

    trait :discretionary do
      mandatory { false }
    end
  end
end
