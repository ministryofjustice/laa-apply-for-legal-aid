module Flow
  module Flows
    class ProviderCapitalDisregards < FlowSteps
      STEPS = {
        capital_disregards_discretionary: Steps::ProviderCapitalDisregards::DiscretionaryStep,
      }.freeze
    end
  end
end
