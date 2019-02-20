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
          forward: :true_layer
        },
        true_layer: {
          path: ->(_) { urls.applicant_true_layer_omniauth_authorize_path }
        },
        accounts: {
          forward: :additional_accounts
        },
        additional_accounts: {
          path: ->(_) { urls.citizens_additional_accounts_path },
          forward: :identify_types_of_income
        }
      }.freeze
    end
  end
end
