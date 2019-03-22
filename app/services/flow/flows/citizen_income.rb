module Flow
  module Flows
    class CitizenIncome < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :income_summary
        },
        income_summary: {
          path: ->(_) { urls.citizens_income_summary_index_path },
          forward: :identify_types_of_outgoings
        },
        identify_types_of_outgoings: {
          path: ->(_) { urls.citizens_identify_types_of_outgoing_path },
          forward: :outgoings_summary
        },
        outgoings_summary: {
          path: ->(_) { urls.citizens_outgoings_summary_index_path },
          forward: :own_homes
        },
        incoming_transactions: {
          forward: :income_summary
        },
        outgoing_transactions: {
          forward: :outgoings_summary
        }
      }.freeze
    end
  end
end
