module Flow
  module Steps
    ProvidersHomeStep = Step.new(
      path: ->(_) { urls.home_path },
    )
  end
end
