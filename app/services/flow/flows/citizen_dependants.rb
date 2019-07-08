module Flow
  module Flows
    class CitizenDependants < FlowSteps
      STEPS = {
        has_dependants: {
          path: ->(_) { urls.citizens_has_dependants_path },
          forward: ->(application) { application.has_dependants? ? :dependants : :identify_types_of_outgoings }
        },
        dependants: {
          path: ->(_) { urls.citizens_dependants_path },
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :other_dependant }
        },
        dependants_details: {
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :other_dependant }
        },
        dependants_relationships: {
          path: ->(_, dependant) { urls.citizens_dependant_relationship_path(dependant) },
          forward: ->(_, dependant) { dependant.adult_relative? || dependant.eighteen_or_less? ? :dependants_income : :dependants_education }
        },
        dependants_education: {
          path: ->(_, dependant) { "[PLACEHOLDER] #{dependant.name} dependants education" }
        },
        dependants_income: {
          path: ->(_, dependant) { "[PLACEHOLDER] #{dependant.name} dependants income" }
        },
        other_dependant: {
          path: '[PLACEHOLDER] do you have any other dependant?'
        }
      }.freeze
    end
  end
end
