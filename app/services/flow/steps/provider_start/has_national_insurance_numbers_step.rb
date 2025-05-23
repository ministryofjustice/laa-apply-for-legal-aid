module Flow
  module Steps
    module ProviderStart
      HasNationalInsuranceNumbersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_has_national_insurance_number_path(application) },
        forward: lambda do |application|
          if application.overriding_dwp_result?
            :check_provider_answers
          else
            :previous_references
          end
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: false,
      )
    end
  end
end
