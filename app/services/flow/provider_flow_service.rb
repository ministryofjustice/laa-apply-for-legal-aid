module Flow
  class ProviderFlowService < BaseFlowService
    steps = {}.deep_merge(Flows::ProviderStart::STEPS)
              .deep_merge(Flows::ProviderProceedingInterrupts::STEPS)
              .deep_merge(Flows::ProviderPartner::STEPS)
              .deep_merge(Flows::ProviderMeansStateBenefits::STEPS)
              .deep_merge(Flows::ProviderProceedingLoop::STEPS)
              .deep_merge(Flows::ProviderDWPOverride::STEPS)
              .deep_merge(Flows::ProviderIncome::STEPS)
              .deep_merge(Flows::ProviderCapital::STEPS)
              .deep_merge(Flows::ProviderCapitalDisregards::STEPS)
              .deep_merge(Flows::ProviderDependants::STEPS)
              .deep_merge(Flows::ProviderMerits::STEPS)
              .deep_merge(Flows::ProviderBlocked::STEPS)

    use_steps(steps.freeze)
  end
end
