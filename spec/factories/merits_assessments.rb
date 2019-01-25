FactoryBot.define do
  factory :merits_assessment do
    legal_aid_application

    trait :with_optional_text do
      client_received_legal_help { false }
      application_purpose { Faker::Lorem.paragraph }
      proceedings_before_the_court { true }
      details_of_proceedings_before_the_court { Faker::Lorem.paragraph }
      # TO DO: statement_of_case { Faker::Lorem.paragraph }
      estimated_legal_cost { Faker::Number.decimal.to_d }
      # TO DO: success_prospect { 'marginal' }
      # TO DO: success_prospect_details { Faker::Lorem.paragraph }
      client_merits_declaration { true }
    end

    trait :without_optional_text do
      client_received_legal_help { true }
      application_purpose { nil }
      proceedings_before_the_court { false }
      details_of_proceedings_before_the_court { nil }
      # TO DO: statement_of_case { Faker::Lorem.paragraph }
      estimated_legal_cost { Faker::Number.decimal.to_d }
      # TO DO: success_prospect { 'better' }
      # TO DO: success_prospect_details { nil }
      client_merits_declaration { true }
    end
  end
end
