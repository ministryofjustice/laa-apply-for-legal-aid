module Flow
  class ProviderFlowService < BaseFlowService
    steps = {}.deep_merge(Flows::ProviderStart::STEPS)
              .deep_merge(Flows::ProviderCapital::STEPS)
              .deep_merge(Flows::VehicleSteps::STEPS)
              .deep_merge(Flows::ProviderMerits::STEPS)

    use_steps(steps.freeze)
  end
end
