module Flow
  module Steps
    ProvidersHomeStep = Step.new(
      path: ->(_) { urls.submitted_providers_legal_aid_applications_path },
    )
  end
end
