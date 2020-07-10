FactoryBot.define do
  factory :permission do
    sequence(:role) { |n| "role_#{n}" }
    sequence(:description) { |n| "The description for role_#{n}" }

    trait :passported do
      role { 'application.passported.*' }
      description { 'Can create, view, modify passported applications' }
    end

    trait :non_passported do
      role { 'application.non_passported.*' }
      description { 'Can create, view, modify non-passported applications' }
    end
  end
end
