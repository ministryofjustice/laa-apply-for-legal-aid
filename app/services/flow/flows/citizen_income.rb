module Flow
  module Flows
    class CitizenIncome < FlowSteps
      STEPS = {
        identify_types_of_income: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :own_homes
        }
      }.freeze
    end
  end
end
