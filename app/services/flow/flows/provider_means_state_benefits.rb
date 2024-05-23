module Flow
  module Flows
    class ProviderMeansStateBenefits < FlowSteps
      STEPS = {
        receives_state_benefits: Steps::ProviderMeansStateBenefits::ReceivesStateBenefitsStep,
        state_benefits: Steps::ProviderMeansStateBenefits::StateBenefitsStep,
        add_other_state_benefits: Steps::ProviderMeansStateBenefits::AddOtherStateBenefitsStep,
        remove_state_benefits: Steps::ProviderMeans::RemoveStateBenefitsStep,
      }.freeze
    end
  end
end
