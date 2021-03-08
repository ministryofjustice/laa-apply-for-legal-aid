module Flow
  module Flows
    class CitizenCapital < FlowSteps
      STEPS = {
        identify_types_of_incomes: {
          path: ->(_) { urls.citizens_identify_types_of_income_path(locale: I18n.locale) },
          forward: ->(application) do
            application.transaction_types.credits.any? ? :cash_incomes : :student_finances
          end,
          check_answers: ->(application) do
            application.transaction_types.credits.any? ? :cash_incomes : :check_answers
          end
        },
        cash_incomes: {
          path: ->(_) { urls.citizens_cash_income_path(locale: I18n.locale) },
          forward: ->(_) { :student_finances },
          check_answers: :check_answers
        },
        student_finances: {
          path: ->(_) { urls.citizens_student_finance_path(locale: I18n.locale) },
          forward: ->(application) do
            application.receives_student_finance? ? :student_finances_annual_amounts : :identify_types_of_outgoings
          end,
          check_answers: ->(application) do
            application.receives_student_finance? ? :student_finances_annual_amounts : :check_answers
          end
        },
        student_finances_annual_amounts: {
          path: ->(_) { urls.citizens_student_finances_annual_amount_path(locale: I18n.locale) },
          forward: :identify_types_of_outgoings,
          check_answers: :check_answers
        },
        identify_types_of_outgoings: {
          path: ->(_) { urls.citizens_identify_types_of_outgoing_path(locale: I18n.locale) },
          forward: ->(application) do
            application.transaction_types.debits.any? ? :cash_outgoings : :check_answers
          end
        },
        cash_outgoings: {
          path: ->(_) { urls.citizens_cash_outgoing_path(locale: I18n.locale) },
          forward: ->(_) { :check_answers }
        }
      }.freeze
    end
  end
end
