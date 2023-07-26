FactoryBot.define do
  factory :opponent, class: "ApplicationMeritsTask::Opponent" do
    legal_aid_application

    for_individual

    transient do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :for_individual do
      opposable factory: :individual

      after(:create) do |opponent, evaluator|
        opponent.opposable.first_name = evaluator.first_name if evaluator.first_name
        opponent.opposable.last_name = evaluator.last_name if evaluator.last_name
        opponent.opposable.save! if evaluator.first_name || evaluator.last_name
      end
    end
  end

  factory :individual, class: "ApplicationMeritsTask::Individual" do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :irish do
      first_name { "Daira" }
      last_name { "O'Braien" }
    end
  end
end
