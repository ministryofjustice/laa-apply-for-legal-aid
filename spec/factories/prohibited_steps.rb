FactoryBot.define do
  factory :prohibited_steps, class: "ProceedingMeritsTask::ProhibitedSteps" do
    uk_removal { true }
    legal_aid_application

    trait :with_data do
      uk_removal { false }
      details { "additional data about steps" }
    end
  end
end
