FactoryBot.define do
  factory :policy_disregards do
    legal_aid_application
    england_infected_blood_support { false }
    vaccine_damage_payments { false }
    variant_creutzfeldt_jakob_disease { false }
    criminal_injuries_compensation_scheme { false }
    national_emergencies_trust { false }
    we_love_manchester_emergency_fund { false }
    london_emergencies_trust { false }

    trait :with_selected_value do
      vaccine_damage_payments { true }
    end

    trait :with_selected_values do
      england_infected_blood_support { true }
      vaccine_damage_payments { true }
      variant_creutzfeldt_jakob_disease { true }
      criminal_injuries_compensation_scheme { true }
      national_emergencies_trust { true }
      we_love_manchester_emergency_fund { true }
      london_emergencies_trust { true }
    end
  end
end
