FactoryBot.define do
  factory :permission do
    sequence(:role) { |n| "role_#{n}" }
    sequence(:description) { |n| "The description for role_#{n}" }

    trait :special_children_act do
      role { "special_children_act" }
      description { "Allow the firm to access SCA proceedings" }
    end
  end
end
