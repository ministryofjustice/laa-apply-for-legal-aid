FactoryBot.define do
  factory :urgency, class: "ApplicationMeritsTask::Urgency" do
    legal_aid_application
    nature_of_urgency { "This is the nature of the urgency" }
  end
end
