module Flow
  module Steps
    module CitizenStart
      TrueLayerStep = Step.new(
        path: ->(_) { FlowSteps.omniauth_login_start_path(:true_layer) },
      )
    end
  end
end
