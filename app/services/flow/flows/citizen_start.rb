module Flow
  module Flows
    module CitizenStart
      STEPS = {
        legal_aid_applications: {
          path: ->(_, urls) { urls.citizens_legal_aid_applications_path },
          forward: :information
        },
        information: {
          back: :legal_aid_applications,
          path: ->(_, urls) { urls.citizens_information_path },
          forward: :consents
        },
        consents: {
          path: ->(_, urls) { urls.citizens_consent_path },
          back: :information,
          forward: :true_layer
        },
        true_layer: {
          path: ->(_, urls) { urls.applicant_true_layer_omniauth_authorize_path }
        },
        accounts: {
          path: ->(_, urls) { urls.citizens_accounts_path },
          back: :consents,
          forward: :additional_accounts
        },
        additional_accounts: {
          path: ->(_, urls) { urls.citizens_additional_accounts_path },
          back: :accounts,
          forward: :own_homes
        }
      }.freeze
    end
  end
end
