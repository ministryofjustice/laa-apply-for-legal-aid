FactoryBot.define do
  factory :opponents_application, class: "ProceedingMeritsTask::OpponentsApplication" do
    has_opponents_application { true }
    proceeding

    trait :with_data do
      has_opponents_application { false }
      reason_for_applying { "additional information about reason for applying" }
    end
  end
end
