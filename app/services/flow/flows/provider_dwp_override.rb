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
          forward: :check_benefits
          # uncomment the below to redirect to next pages being developed and remove line 7
          # forward: ->(_application, confirm_dwp_non_passported) { confirm_dwp_non_passported ? :check_benefits : :check_client_details }
        },
        place_holder_check_client_details: {
          path: '[PLACEHOLDER] Page for provider to check client details',
          forward: :has_evidence_of_benefits
        },
        has_evidence_of_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_has_evidence_of_benefit_path(application) },
          forward: ->(application) { application.dwp_override.has_evidence_of_benefit ? :evidence_of_benefit : :place_holder_tbc_design }
        },
        evidence_of_benefit: {
          path: ->(application) { urls.providers_legal_aid_application_evidence_of_benefit_path(application) }
        },
        place_holder_tbc_design: {
          path: '[PLACEHOLDER] Page if provider has no evidence of benefit'
        }
      }.freeze
    end
  end
end
