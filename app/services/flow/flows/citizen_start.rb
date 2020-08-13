module Flow
  module Flows
    class CitizenStart < FlowSteps
      STEPS = {
        legal_aid_applications: {
          path: ->(_) { urls.citizens_legal_aid_applications_path },
          forward: :information
        },
        information: {
          path: ->(_) { urls.citizens_information_path },
          forward: :consents,
          back: :legal_aid_applications
        },
        consents: {
          path: ->(_) { urls.citizens_consent_path },
          forward: ->(application) do
            application.open_banking_consent ? :banks : :contact_providers
          end
        },
        contact_providers: {
          path: ->(_) { urls.citizens_contact_provider_path }
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
          forward: ->(application) do
            application.has_offline_accounts? ? :contact_providers : :identify_types_of_incomes
          end
        }
      }.freeze
    end
  end
end
