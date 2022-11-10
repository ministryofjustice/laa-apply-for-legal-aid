module ApplicationMeritsTask
  FactoryBot.define do
    factory :matter_opposition, class: "ApplicationMeritsTask::MatterOpposition" do
      legal_aid_application
      reason { "A reason to oppose the matter." }
    end
  end
end
