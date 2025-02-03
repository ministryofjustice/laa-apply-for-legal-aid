FactoryBot.define do
  factory :permission do
    sequence(:role) { |n| "role_#{n}" }
    sequence(:description) { |n| "The description for role_#{n}" }

    trait :dummy_permission do
      role { "dummy_permission" }
      description { "Allow the firm to have a dummy permission" }
    end
  end
end
