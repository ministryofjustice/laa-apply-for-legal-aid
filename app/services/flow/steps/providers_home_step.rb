module Flow
  module Steps
    ProvidersHomeStep = Step.new(
      path: ->(_application) { urls.providers_legal_aid_applications_path },
    )
  end
end
