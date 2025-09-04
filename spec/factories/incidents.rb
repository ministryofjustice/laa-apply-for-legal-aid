FactoryBot.define do
  factory :incident, class: "ApplicationMeritsTask::Incident" do
    told_on { Faker::Date.backward(days: 90) }
    occurred_on { Faker::Date.backward(days: 90) - 1.year }
    first_contact_date { Faker::Date.backward(days: 90) }
    details { Faker::Lorem.paragraph }
    legal_aid_application
  end
end
