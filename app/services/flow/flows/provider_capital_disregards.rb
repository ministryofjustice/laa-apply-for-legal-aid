module Flow
  module Flows
    class ProviderCapitalDisregards
      STEPS = {
        capital_disregards_discretionary: Steps::ProviderCapitalDisregards::DiscretionaryStep,
        capital_disregards_mandatory: Steps::ProviderCapitalDisregards::MandatoryStep,
        capital_disregards_add_details: Steps::ProviderCapitalDisregards::AddDetailsStep,
      }.freeze
    end
  end
end
