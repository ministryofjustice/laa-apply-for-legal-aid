FactoryBot.define do
  factory :feedback do
    done_all_needed { Faker::Boolean.boolean }
    satisfaction { Feedback.satisfactions.keys.sample }
    difficulty { Feedback.difficulties.keys.sample }
    improvement_suggestion { Faker::Lorem.paragraph }
    os { %w[Linux Windows Mac].sample }
    browser { %w[IE Chrome Safari Firefox Opera].sample }
    browser_version { Faker::App.semantic_version }
    source { %w[Providers Citizens Unknown].sample }

    trait :with_timestamps do
      created_at { Faker::Time.backward }
      updated_at { Faker::Time.backward }
    end
  end
end
