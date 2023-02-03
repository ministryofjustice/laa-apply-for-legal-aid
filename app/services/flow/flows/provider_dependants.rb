module Flow
  module Flows
    class ProviderDependants < FlowSteps
      STEPS = {
        has_dependants: {
          path: ->(application) { urls.providers_legal_aid_application_means_has_dependants_path(application) },
          forward: lambda do |application|
            if application.has_dependants?
              :dependants
            else
              :check_income_answers
            end
          end,
          check_answers: lambda do |application|
            if application.has_dependants?
              if application.dependants.count.positive?
                :has_other_dependants
              else
                :dependants
              end
            else
              :check_income_answers
            end
          end,
        },
        dependants: {
          path: ->(application) { urls.new_providers_legal_aid_application_means_dependant_path(application) },
          forward: :has_other_dependants,
        },
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
