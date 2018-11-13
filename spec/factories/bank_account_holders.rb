FactoryBot.define do
  factory :bank_account_holder do
    bank_provider
    full_name { Faker::Name.name }
    date_of_birth { Faker::Date.backward }
  end
end
