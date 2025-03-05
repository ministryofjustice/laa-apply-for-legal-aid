FactoryBot.define do
  factory :feedback do
    done_all_needed { Faker::Boolean.boolean }
    done_all_needed_reason { nil }
    satisfaction { Feedback.satisfactions.keys.sample }
    satisfaction_reason { Faker::Lorem.paragraph }
    difficulty { Feedback.difficulties.keys.sample }
    difficulty_reason { Faker::Lorem.paragraph }
    time_taken_satisfaction { Feedback.time_taken_satisfactions.keys.sample }
    time_taken_satisfaction_reason { Faker::Lorem.paragraph }
    improvement_suggestion { Faker::Lorem.paragraph }
    os { %w[Linux Windows Mac].sample }
    browser { %w[IE Chrome Safari Firefox Opera].sample }
    browser_version { Faker::App.semantic_version }
    source { %w[Provider Citizen Unknown].sample }
    originating_page { "http://localhost:3000/applications" }
    email { "me@example.com" }

    trait :with_timestamps do
      created_at { Faker::Time.backward }
      updated_at { Faker::Time.backward }
    end

    trait :from_provider do
      source { "Provider" }
    end
  end
end
