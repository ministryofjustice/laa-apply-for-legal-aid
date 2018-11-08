FactoryBot.define do
  factory :bank_provider do
    applicant
    credentials_id { SecureRandom.hex }
    token { SecureRandom.hex }
    name { Faker::Bank.name }
    true_layer_provider_id { SecureRandom.hex }
  end
end
