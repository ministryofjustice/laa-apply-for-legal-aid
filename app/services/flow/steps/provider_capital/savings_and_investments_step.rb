module Flow
  module Steps
    module ProviderCapital
      SavingsAndInvestmentsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_savings_and_investment_path(application) },
        forward: lambda do |application|
          if application.own_capital? && application.checking_answers?
            :restrictions
          else
            :other_assets
          end
        end,
        carry_on_sub_flow: ->(application) { application.own_capital? },
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
