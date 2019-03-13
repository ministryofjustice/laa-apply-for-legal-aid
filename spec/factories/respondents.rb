FactoryBot.define do
  factory :respondent do
    legal_aid_application
    understands_terms_of_court_order { Faker::Boolean.boolean }
    understands_terms_of_court_order_details { Faker::Lorem.paragraph }
    warning_letter_sent { Faker::Boolean.boolean }
    warning_letter_sent_details { Faker::Lorem.paragraph }
    police_notified { Faker::Boolean.boolean }
    police_notified_details { Faker::Lorem.paragraph }
    bail_conditions_set { Faker::Boolean.boolean }
    bail_conditions_set_details { Faker::Lorem.paragraph }
  end
end
