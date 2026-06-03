FactoryBot.define do
  factory :admin_user do
    username { Faker::Internet.username }
    role { :full }

    trait :digest_only do
      role { :digest_only }
    end
  end
end
