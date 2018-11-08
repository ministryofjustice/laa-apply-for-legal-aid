FactoryBot.define do
  factory :secure_data, class: 'SecureData' do
    data { JWT.encode( { data: Faker::Lorem.sentence }, nil, 'none') }
  end
end
