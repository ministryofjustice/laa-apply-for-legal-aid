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
          forward: :own_homes
        },
        identify_types_of_outgoings: {
          # path: ->(_) { urls.citizens_identify_types_of_outgoing_path }, # TODO: implement when navigation from preceding page is required
          forward: :own_homes # TODO: replace with correct page when known
        },
        transactions: {
          forward: :income_summary
        }
      }.freeze
    end
  end
end
