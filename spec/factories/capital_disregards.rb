FactoryBot.define do
  factory :capital_disregard do
    legal_aid_application
    name { "backdated_benefits" }
    amount { nil }
    date_received { nil }
    payment_reason { nil }
    account_name { nil }
    mandatory { true }

    trait :discretionary do
      mandatory { false }
    end

    trait :mandatory do
      mandatory { true }
    end
  end
end
