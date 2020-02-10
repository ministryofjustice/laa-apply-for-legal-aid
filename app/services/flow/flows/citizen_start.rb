module Flow
  module Flows
    class CitizenStart < FlowSteps
      STEPS = {
        legal_aid_applications: {
          forward: :information
        },
        information: {
          path: ->(_) { urls.citizens_information_path },
          forward: :consents
        },
        consents: {
          path: ->(_) { urls.citizens_consent_path },
          forward: :banks
        },
        banks: {
          path: ->(_) { urls.citizens_banks_path },
          forward: :true_layer
        },
        true_layer: {
          path: ->(_) { omniauth_login_start_path(:true_layer) }
        },
        accounts: {
          forward: :additional_accounts,
          check_answers: :check_answers
        },
        additional_accounts: {
          path: ->(_) { urls.citizens_additional_accounts_path },
          forward: :identify_types_of_incomes
        }
      }.freeze
    end
  end
end
