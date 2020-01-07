module Flow
  module Flows
    class CitizenCapital < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :identify_types_of_outgoings,
          check_answers: :check_answers
        },
        # Dependants steps were here (see CitizenDependants)
        # They were removed Jan 2020 as the citizen path was simplified
        # and moved to the provider.
        identify_types_of_outgoings: {
          path: ->(_) { urls.citizens_identify_types_of_outgoing_path },
          forward: :check_answers,
          check_answers: :check_answers
        },
        check_answers: {
          path: ->(_) { urls.citizens_check_answers_path },
          forward: :declarations
        },
        declarations: {
          path: ->(_) { urls.citizens_declaration_path },
          forward: :means_test_results
        },
        means_test_results: {
          path: ->(_) { urls.citizens_means_test_result_path },
          forward: nil
        }
      }.freeze
    end
  end
end
