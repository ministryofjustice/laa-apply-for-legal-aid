module Flow
  module Steps
    module ProviderCapitalDisregards
      MandatoryStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_capital_disregards_mandatory_path(application) },
        forward: lambda do |_application, disregard|
          if disregard
            :capital_disregards_add_details
          else
            :capital_disregards_discretionary
          end
        end,
        check_answers: lambda do |application, disregard|
          if disregard
            :capital_disregards_add_details
          else
            application.passported? ? :check_passported_answers : :check_capital_answers
          end
        end,
      )
    end
  end
end
