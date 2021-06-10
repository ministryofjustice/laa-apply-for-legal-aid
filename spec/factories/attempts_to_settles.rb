FactoryBot.define do
  factory :attempts_to_settles, class: ProceedingMeritsTask::AttemptsToSettle do
    attempts_made { Faker::Lorem.sentence }
  end
end
