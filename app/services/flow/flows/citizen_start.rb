module Flow
  module Flows
    module CitizenStart
      STEPS = {
        legal_aid_applications: {
          forward: :information
        },
        information: {
          path: ->(_, urls) { urls.citizens_information_path },
          forward: :consents
        },
        consents: {
          path: ->(_, urls) { urls.citizens_consent_path },
          forward: :true_layer
        },
        true_layer: {
          path: ->(_, urls) { urls.applicant_true_layer_omniauth_authorize_path }
        },
        accounts: {
          forward: :additional_accounts
        },
        additional_accounts: {
          path: ->(_, urls) { urls.citizens_additional_accounts_path },
          forward: :own_homes
        }
      }.freeze
    end
  end
end
