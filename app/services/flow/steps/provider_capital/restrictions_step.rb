module Flow
  module Steps
    module ProviderCapital
      RestrictionsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_restrictions_path(application) },
        forward: lambda do |application|
          if application.capture_policy_disregards?
            :capital_disregards_mandatory
          else
            application.passported? ? :check_passported_answers : :check_capital_answers
          end
        end,
        check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
