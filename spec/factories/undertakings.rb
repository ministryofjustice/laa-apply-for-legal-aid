FactoryBot.define do
  factory :undertaking, class: "ApplicationMeritsTask::Undertaking" do
    offered { true }
    legal_aid_application

    trait :with_data do
      offered { false }
      additional_information { "extenuating circumstances" }
    end
  end
end
