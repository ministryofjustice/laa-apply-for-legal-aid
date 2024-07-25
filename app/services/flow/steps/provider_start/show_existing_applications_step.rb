module Flow
  module Steps
    module ProviderStart
      ShowExistingApplicationsStep = Step.new(
        path: ->(_) { Steps.urls.new_providers_show_existing_application_path },
      )
    end
  end
end
