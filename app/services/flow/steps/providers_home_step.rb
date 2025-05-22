module Flow
  module Steps
    ProvidersHomeStep = Step.new(
      path: ->(_) { urls.in_progress_providers_legal_aid_applications_path },
    )
  end
end
