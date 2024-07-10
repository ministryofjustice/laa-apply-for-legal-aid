module Flow
  module Steps
    module ProviderIncome
      RegularOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_regular_outgoings_path(application) },
        forward: lambda do |application|
          if application.applicant_outgoing_types?
            :cash_outgoings
          elsif application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          else
            :has_dependants
          end
        end,
        check_answers: ->(application) { application.applicant_outgoing_types? ? :cash_outgoings : :check_income_answers },
      )
    end
  end
end
