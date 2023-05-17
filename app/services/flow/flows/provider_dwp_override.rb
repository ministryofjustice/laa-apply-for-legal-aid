module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps
      STEPS = {
        confirm_dwp_non_passported_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
          forward: lambda do |application, confirm_dwp_non_passported|
            if confirm_dwp_non_passported
              application.change_state_machine_type("NonPassportedStateMachine")
              :about_financial_means
            else
              application.check_applicant_details! unless application.checking_applicant_details?
              application.change_state_machine_type("PassportedStateMachine")
              :check_client_details
            end
          end,
        },
        check_client_details: {
          path: ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) },
          forward: ->(_application, correct_details) { correct_details ? :received_benefit_confirmations : :applicant_details },
        },
        received_benefit_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_received_benefit_confirmation_path(application) },
          forward: lambda do |application, has_benefit|
            if has_benefit
              application.change_state_machine_type("PassportedStateMachine")
              :has_evidence_of_benefits
            else
              application.change_state_machine_type("NonPassportedStateMachine")
              :about_financial_means
            end
          end,
        },
        has_evidence_of_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_has_evidence_of_benefit_path(application) },
          forward: lambda do |application, has_evidence_of_benefit|
            if has_evidence_of_benefit
              application.change_state_machine_type("PassportedStateMachine")
              application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              application.change_state_machine_type("NonPassportedStateMachine")
              :about_financial_means
            end
          end,
        },
      }.freeze
    end
  end
end
