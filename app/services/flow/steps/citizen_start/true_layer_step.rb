module Flow
  module Steps
    module CitizenStart
      TrueLayerStep = Step.new(
        path: ->(_) { "/auth/true_layer" },
      )
    end
  end
end
