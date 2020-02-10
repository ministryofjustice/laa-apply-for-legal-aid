module Flow
  module Flows
    class CitizenCapital < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :identify_types_of_outgoings,
          check_answers: :check_answers
        },
        identify_types_of_outgoings: {
          path: ->(_) { urls.citizens_identify_types_of_outgoing_path },
          forward: :check_answers
        }
      }.freeze
    end
  end
end
