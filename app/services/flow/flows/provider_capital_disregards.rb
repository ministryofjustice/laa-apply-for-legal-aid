module Flow
  module Flows
    class ProviderCapitalDisregards < FlowSteps
      STEPS = {
        capital_disregards_discretionary: Steps::ProviderCapitalDisregards::DiscretionaryStep,
        capital_disregards_mandatory: Steps::ProviderCapitalDisregards::MandatoryStep,
      }.freeze
    end
  end
end
