module ProceedingMeritsTask
  FactoryBot.define do
    factory :application_proceeding_type_involved_child, class: ProceedingMeritsTask::ApplicationProceedingTypeInvolvedChild do
      involved_child
      application_proceeding_type
    end
  end
end
