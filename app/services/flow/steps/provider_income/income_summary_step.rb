module Flow
  module Steps
    module ProviderIncome
      IncomeSummaryStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_income_summary_index_path(application) },
        forward: lambda do |application|
          if application.outgoing_types?
            :outgoings_summary
          elsif application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          else
            :has_dependants
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
