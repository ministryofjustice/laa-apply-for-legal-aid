module Flow
  module Flows
    class ProviderDependants < FlowSteps
      STEPS = {
        has_dependants: Steps::ProviderDependants::HasDependantsStep,
        dependants: Steps::ProviderDependants::DependantsStep,
        has_other_dependants: Steps::ProviderDependants::HasOtherDependantsStep,
        remove_dependants: {
          path: ->(application, dependant) { urls.providers_legal_aid_application_means_remove_dependant_path(application, dependant) },
          forward: ->(application) { application.dependants.any? ? :has_other_dependants : :has_dependants },
        },
      }.freeze
    end
  end
end
