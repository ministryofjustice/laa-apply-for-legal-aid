module Flow
  module Steps
    module ProviderStart
      SearchExistingApplicationsStep = Step.new(
        path: ->(_) { Steps.urls.new_providers_search_existing_application_path },
      )
    end
  end
end
