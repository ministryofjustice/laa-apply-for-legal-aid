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
          path: ->(_, dependant) { "[PLACEHOLDER] - #{dependant.name} - dependant relationship" }
        },
        other_dependant: {
          path: '[PLACEHOLDER] do you have any other dependant?'
        }
      }.freeze
    end
  end
end
