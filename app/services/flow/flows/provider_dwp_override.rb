module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        confirm_dwp_non_passported_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
<<<<<<< HEAD
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
          path: ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) }
=======
          forward: :received_benefit_confirmation
          # uncomment the below to redirect to next pages being developed and remove line 7
          # forward: ->(_application, confirm_dwp_non_passported) { confirm_dwp_non_passported ? :check_benefits : :check_client_details }
        },
        # check_client_details: {
        #   path: ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) },
        #   forward: :received_benefit_confirmation
        # },
        received_benefit_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_received_benefit_confirmation_path(application) },
          forward: :check_benefits
>>>>>>> 44869594 (WIP)
        }
      }.freeze
    end
  end
end
