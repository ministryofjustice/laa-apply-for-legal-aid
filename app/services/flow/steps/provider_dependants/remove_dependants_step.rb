module Flow
  module Steps
    module ProviderDependants
      RemoveDependantsStep = Step.new(
        path: ->(application, dependant) { Steps.urls.providers_legal_aid_application_means_remove_dependant_path(application, dependant) },
        forward: ->(application) { application.dependants.any? ? :has_other_dependants : :has_dependants },
      )
    end
  end
end
