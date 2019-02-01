FactoryBot.define do
  factory :statement_of_case do
    legal_aid_application

    statement { Faker::Lorem.paragraph }
  end
end
