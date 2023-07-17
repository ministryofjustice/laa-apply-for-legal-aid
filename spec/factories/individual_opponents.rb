FactoryBot.define do
  factory :individual_opponent, class: "ApplicationMeritsTask::Opponent::Individual" do
    legal_aid_application
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :irish do
      first_name { "Daira" }
      last_name { "O'Braien" }
    end
  end
end
