module Flow
  class CitizenFlowService < BaseFlowService
    steps = {}.deep_merge(Flows::CitizenStart::STEPS)
              .deep_merge(Flows::CitizenCapital::STEPS)
              .deep_merge(Flows::CitizenVehicle::STEPS)

    use_steps(steps.freeze)
  end
end
