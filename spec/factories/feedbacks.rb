FactoryBot.define do
  factory :feedback do
    done_all_needed { Faker::Boolean.boolean }
    satisfaction { Feedback.satisfactions.keys.sample }
    improvement_suggestion { Faker::Lorem.paragraph }
  end
end
