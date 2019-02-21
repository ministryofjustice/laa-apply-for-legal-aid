module Flow
  module Flows
    class CitizenIncome < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :own_homes
        },
        transactions: {
          forward: :placeholder_summary_transaction
        },
        placeholder_summary_transaction: {
          path: '[PLACEHOLDER] Summary of income or payments'
        }
      }.freeze
    end
  end
end
