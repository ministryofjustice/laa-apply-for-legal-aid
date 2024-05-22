module Flow
  module Flows
    class ProviderBlocked < FlowSteps
      STEPS = {
        providers_blocked: Steps::ProviderBlocked::ProvidersBlockedStep,
      }.freeze
    end
  end
end
