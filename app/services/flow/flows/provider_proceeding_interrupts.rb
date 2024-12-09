module Flow
  module Flows
    class ProviderProceedingInterrupts < FlowSteps
      STEPS = {
        related_orders: Steps::Provider::ProceedingInterrupts::RelatedOrdersStep,
      }.freeze
    end
  end
end
