module Flow
  class ProviderFlowService < BaseFlowService
    steps = {}.deep_merge(Flows::ProviderStart::STEPS)
              .deep_merge(Flows::ProviderDWPOverride::STEPS)
              .deep_merge(Flows::ProviderDependants::STEPS)
              .deep_merge(Flows::ProviderCapital::STEPS)
              .deep_merge(Flows::ProviderProperty::STEPS)
              .deep_merge(Flows::ProviderVehicle::STEPS)
              .deep_merge(Flows::ProviderMerits::STEPS)

    use_steps(steps.freeze)
  end
end
