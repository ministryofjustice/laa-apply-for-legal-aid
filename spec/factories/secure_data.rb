FactoryBot.define do
  factory :secure_data, class: 'SecureData' do
    after(:build) do |secure_data|
      secure_data.store(data: Faker::Lorem.sentence)
    end
  end
end
