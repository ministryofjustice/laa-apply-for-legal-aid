module ProceedingMeritsTask
  FactoryBot.define do
    factory :proceeding_linked_child, class: "ProceedingMeritsTask::ProceedingLinkedChild" do
      involved_child
      proceeding
    end
  end
end
