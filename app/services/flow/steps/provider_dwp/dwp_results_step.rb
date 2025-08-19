module Flow
  module Steps
    module ProviderDWP
      DWPResultsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_dwp_result_path(application) },
        forward: lambda do |application|
          case application.benefit_check_status
          when :unsuccessful
            :dwp_fallback
          when :positive
            application.change_state_machine_type("PassportedStateMachine")
            application.used_delegated_functions? ? :substantive_applications : :capital_introductions
          else
            application.change_state_machine_type("NonPassportedStateMachine")
            :about_financial_means
          end
        end,
      )
    end
  end
end
