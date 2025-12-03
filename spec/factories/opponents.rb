FactoryBot.define do
  factory :opponent, class: "ApplicationMeritsTask::Opponent" do
    legal_aid_application
    for_individual

    transient do
      first_name { nil }
      last_name { nil }
      organisation_name { nil }
      organisation_ccms_type_code { nil }
      organisation_ccms_type_text { nil }
    end

    trait :for_individual do
      opposable factory: :individual

      after(:build) do |opponent, evaluator|
        opponent.opposable.first_name = evaluator.first_name if evaluator.first_name
        opponent.opposable.last_name = evaluator.last_name if evaluator.last_name
        opponent.opposable.save! if evaluator.first_name || evaluator.last_name
      end
    end

    trait :for_organisation do
      opposable factory: :organisation

      after(:build) do |opponent, evaluator|
        opponent.ccms_opponent_id { evaluator.ccms_opponent_id } if evaluator.ccms_opponent_id
        opponent.opposable.name = evaluator.organisation_name if evaluator.organisation_name
        opponent.opposable.ccms_type_code = evaluator.organisation_ccms_type_code if evaluator.organisation_ccms_type_code
        opponent.opposable.ccms_type_text = evaluator.organisation_ccms_type_text if evaluator.organisation_ccms_type_text
        opponent.opposable.save! if evaluator.organisation_name || evaluator.organisation_ccms_type_code || evaluator.organisation_ccms_type_text
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
    ccms_type_code { "LA" }
    ccms_type_text { "Local Authority" }
  end
end
