FactoryBot.define do
  factory :benefit_check_result do
    legal_aid_application
    result { 'No' }
    dwp_ref { SecureRandom.hex }
  end
end
