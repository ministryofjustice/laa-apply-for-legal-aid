module Flow
  module Steps
    module ProviderCapitalDisregards
      AddDetailsStep = Step.new(
        path: lambda do |application, disregard|
          Steps.urls.providers_legal_aid_application_means_capital_disregards_add_detail_path(application, disregard)
        end,
        forward: lambda do |application, disregard|
          if disregard
            :capital_disregards_add_details
          elsif application.mandatory_capital_disregards && application.discretionary_capital_disregards.empty?
            :capital_disregards_discretionary
          else
            application.passported? ? :check_passported_answers : :check_capital_answers
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
