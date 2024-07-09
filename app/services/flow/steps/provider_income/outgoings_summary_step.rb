module Flow
  module Steps
    module ProviderIncome
      OutgoingsSummaryStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
        forward: lambda do |application|
          if application.applicant.has_partner_with_no_contrary_interest?
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
