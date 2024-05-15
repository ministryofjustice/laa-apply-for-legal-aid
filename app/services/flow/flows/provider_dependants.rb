module Flow
  module Flows
    class ProviderDependants < FlowSteps
      STEPS = {
        has_dependants: Steps::ProviderDependants::HasDependantsStep,
        dependants: Steps::ProviderDependants::DependantsStep,
        has_other_dependants: {
          path: ->(application) { urls.providers_legal_aid_application_means_has_other_dependants_path(application) },
          forward: lambda { |_application, has_other_dependant|
            has_other_dependant ? :dependants : :check_income_answers
          },
          check_answers: lambda { |_application, has_other_dependant|
            has_other_dependant ? :dependants : :check_income_answers
          },
        },
        remove_dependants: {
          path: ->(application, dependant) { urls.providers_legal_aid_application_means_remove_dependant_path(application, dependant) },
          forward: ->(application) { application.dependants.any? ? :has_other_dependants : :has_dependants },
        },
      }.freeze
    end
  end
end
