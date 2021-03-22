FactoryBot.define do
  factory :dwp_override do
    legal_aid_application

    passporting_benefit { 'universal_credit' }
    has_evidence_of_benefit { nil }
  end
end
