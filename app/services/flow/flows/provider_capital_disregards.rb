module Flow
  module Flows
    class ProviderCapitalDisregards < FlowSteps
      STEPS = {
        capital_disregards_discretionary: Steps::ProviderCapitalDisregards::DiscretionaryStep,
        mandatory: Steps::ProviderCapitalDisregards::MandatoryStep,
      }.freeze
    end
  end
end
