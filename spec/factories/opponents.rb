FactoryBot.define do
  factory :opponent, class: 'ApplicationMeritsTask::Opponent' do
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

    trait :police_notified_false do
      police_notified { false }
      police_notified_details { 'details for non-notification of police' }
    end

    trait :police_notified_true do
      police_notified { true }
      police_notified_details { 'details for police notification' }
    end
  end
end
