FactoryBot.define do
  factory :dwp_override do
    legal_aid_application
    passporting_benefit { 'Universal Credit' }
    evidence_available { true }

    trait 'no evidence_available' do
      evidence_available { false }
    end
  end
end
