FactoryBot.define do
  factory :dwp_override do
    legal_aid_application

    passporting_benefit { Faker::Name.name }
    has_evidence_of_benefit { nil }
  end
end
