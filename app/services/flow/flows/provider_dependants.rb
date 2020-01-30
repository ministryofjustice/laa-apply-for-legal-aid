module Flow
  module Flows
    class ProviderDependants < FlowSteps
      STEPS = {
        has_dependants: {
          path: ->(application) { urls.providers_legal_aid_application_has_dependants_path(application) },
          forward: ->(application) { application.has_dependants? ? :dependants : :outgoings_summary }
        },
        dependants: {
          path: ->(application) { urls.providers_legal_aid_application_dependants_path(application) },
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :has_other_dependants }
        },
        dependants_details: {
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :has_other_dependants }
        },
        dependants_relationships: {
          path: ->(application, params) do
            urls.providers_legal_aid_application_dependant_relationship_path(application, params.is_a?(Dependant) ? params.id : params.slice(:dependant_id))
          end,
          forward: ->(_, dependant) do
            dependant.adult_relative? || dependant.eighteen_or_less? ? :dependants_monthly_incomes : :dependants_full_time_educations
          end
        },
        dependants_assets_values: {
          path: ->(application, dependant) { urls.providers_legal_aid_application_dependant_assets_value_path(application, dependant) },
          forward: :has_other_dependants
        },
        dependants_monthly_incomes: {
          path: ->(application, dependant) { urls.providers_legal_aid_application_dependant_monthly_income_path(application, dependant) },
          forward: ->(_, dependant) do
            dependant.in_full_time_education? || dependant.eighteen_or_less? ? :has_other_dependants : :dependants_assets_values
          end
        },
        has_other_dependants: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_dependant_path(application) },
          forward: ->(_, has_other_dependant) { has_other_dependant ? :dependants : :outgoings_summary }
        },
        dependants_full_time_educations: {
          path: ->(application, dependant) { urls.providers_legal_aid_application_dependant_full_time_education_path(application, dependant) },
          forward: :dependants_monthly_incomes
        }
      }.freeze
    end
  end
end
