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
          forward: ->(application, correct_details) do
            if correct_details
              # this needs to be moved to the last step in the override flow
              # and replaced here with the next :confirm_benefits steps
              application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              :applicant_details
            end
          end
        }
      }.freeze
    end
  end
end
