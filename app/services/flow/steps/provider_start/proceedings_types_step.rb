module Flow
  module Steps
    module ProviderStart
      ProceedingsTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_proceedings_types_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
