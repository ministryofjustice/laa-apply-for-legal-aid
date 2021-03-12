module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        confirm_dwp_non_passported_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
          forward: ->(application, confirm_dwp_non_passported) do
            if confirm_dwp_non_passported
              application.change_state_machine_type('NonPassportedStateMachine')
              :applicant_employed
            else
              application.change_state_machine_type('PassportedStateMachine')
              :check_client_details
            end
          end
        },
        check_client_details: {
          path: ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) },
          forward: :received_benefit_confirmation
        },
        # check_client_details: {
        #   path: ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) },
        #   forward: :received_benefit_confirmation
        # },
        received_benefit_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_received_benefit_confirmation_path(application) },
          forward: ->(_application, has_benefit) do
            if has_benefit
              # this needs to be moved to the last step in the override flow
              # and replaced here with the next :confirm_benefits steps
              _application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              :applicant_employed
            end
          end
        }
      }.freeze
    end
  end
end
