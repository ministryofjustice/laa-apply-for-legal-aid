FactoryBot.define do
  factory :opponent, class: "ApplicationMeritsTask::Opponent" do
    legal_aid_application
    for_individual

    transient do
      first_name { nil }
      last_name { nil }
      organisation_name { nil }
      organisation_ccms_code { nil }
      organisation_description { nil }
    end

    trait :for_individual do
      opposable factory: :individual

      after(:build) do |opponent, evaluator|
        opponent.opposable.first_name = evaluator.first_name if evaluator.first_name
        opponent.opposable.last_name = evaluator.last_name if evaluator.last_name
      end
    end

    trait :for_organisation do
      opposable factory: :organisation

      after(:build) do |opponent, evaluator|
        opponent.opposable.name = evaluator.organisation_name if evaluator.organisation_name
        opponent.opposable.ccms_code = evaluator.organisation_ccms_code if evaluator.organisation_ccms_code
        opponent.opposable.description = evaluator.organisation_description if evaluator.organisation_description
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

  factory :organisation, class: "ApplicationMeritsTask::Organisation" do
    name { Faker::Company.name }
    ccms_code { "LA" }
    description { "Local Authority" }
  end
end
