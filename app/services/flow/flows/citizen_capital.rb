module Flow
  module Flows
    class CitizenCapital < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path },
          forward: :student_finances,
          check_answers: :check_answers
        },
        student_finances: {
            path: ->(_) { urls.citizens_student_finance_path },
            forward: ->(application) do
              application.new_receives_student_finance? ? :student_finance_amounts : :identify_types_of_outgoings
            end
        },
        student_finance_amounts: {
            path: ->(_) { urls.citizens_student_finances_annual_amount_path },
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
