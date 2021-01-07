FactoryBot.define do
  factory :respondent do
    legal_aid_application
    full_name { Faker::Name.name }
    understands_terms_of_court_order { 'false' }
    understands_terms_of_court_order_details { Faker::Lorem.paragraph }
    warning_letter_sent { 'false' }
    warning_letter_sent_details { Faker::Lorem.paragraph }
    police_notified { %w[true false].sample }
    police_notified_details { Faker::Lorem.paragraph }
    bail_conditions_set { 'true' }
    bail_conditions_set_details { Faker::Lorem.paragraph }

    trait :irish do
      full_name { "Daira O'Braien" }
    end
  end
end
