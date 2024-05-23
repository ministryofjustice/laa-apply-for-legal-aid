module Flow
  module Steps
    module ProviderStart
      LimitationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_limitations_path(application) },
        forward: :has_national_insurance_numbers,
        check_answers: :check_provider_answers,
      )
    end
  end
end
