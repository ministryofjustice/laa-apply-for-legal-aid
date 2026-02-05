module Flow
  module Steps
    module ProviderStart
      NoNationalInsuranceNumbersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_no_national_insurance_number_path(application) },
        forward: lambda do |application|
          application.change_state_machine_type("NonPassportedStateMachine")
          :about_financial_means
        end,
      )
    end
  end
end
