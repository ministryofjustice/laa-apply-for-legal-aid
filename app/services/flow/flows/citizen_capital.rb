module Flow
  module Flows
    class CitizenCapital < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path(locale: I18n.locale) },
          forward: ->(_) { Setting.allow_cash_payment? ? :cash_income : :student_finances },
          check_answers: :check_answers
        },
        cash_income: {
          path: ->(_) { urls.citizens_cash_income_path(locale: I18n.locale) },
          forward: ->(_) { :student_finances },
          check_answers: :check_answers
        },
        student_finances: {
          path: ->(_) { urls.citizens_student_finance_path(locale: I18n.locale) },
          forward: ->(application) do
                     application.receives_student_finance? ? :student_finances_annual_amounts : :identify_types_of_outgoings
                   end
        },
        student_finances_annual_amounts: {
          path: ->(_) { urls.citizens_student_finances_annual_amount_path(locale: I18n.locale) },
          forward: :identify_types_of_outgoings
        },
        identify_types_of_outgoings: {
          path: ->(_) { urls.citizens_identify_types_of_outgoing_path(locale: I18n.locale) },
          forward: :check_answers
        }
      }.freeze
    end
  end
end
