FactoryBot.define do
  factory :parties_mental_capacity, class: "ApplicationMeritsTask::PartiesMentalCapacity" do
    legal_aid_application
    understands_terms_of_court_order { "false" }
    understands_terms_of_court_order_details { Faker::Lorem.paragraph }
  end
end
