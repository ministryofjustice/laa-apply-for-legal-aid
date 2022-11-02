FactoryBot.define do
  factory :vary_order, class: "ProceedingMeritsTask::VaryOrder" do
    proceeding
    details { "reason why a new application to vary the order is required" }
  end
end
