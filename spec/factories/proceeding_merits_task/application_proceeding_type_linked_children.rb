module ProceedingMeritsTask
  FactoryBot.define do
    factory :application_proceeding_type_linked_child, class: ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild do
      involved_child
      application_proceeding_type
    end
  end
end
