module Flow
  module Flows
    class ProviderProceedingInterrupts
      STEPS = {
        related_orders: Steps::Provider::ProceedingInterrupts::RelatedOrdersStep,
      }.freeze
    end
  end
end
