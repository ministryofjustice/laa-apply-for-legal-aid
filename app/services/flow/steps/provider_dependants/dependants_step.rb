module Flow
  module Steps
    module ProviderDependants
      DependantsStep = Step.new(
        path: ->(application) { Steps.urls.new_providers_legal_aid_application_means_dependant_path(application) },
        forward: :has_other_dependants,
      )
    end
  end
end
