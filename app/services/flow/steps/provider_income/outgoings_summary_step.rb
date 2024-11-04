module Flow
  module Steps
    module ProviderIncome
      OutgoingsSummaryStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
        forward: lambda do |application|
          if application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          elsif application.housing_payments_for?("Applicant")
            :housing_benefits
          else
            :has_dependants
          end
        end,
        check_answers: lambda do |application|
          if application.housing_payments_for?("Applicant") || application.housing_payments_for?("Partner")
            :housing_benefits
          else
            :check_income_answers
          end
        end,
      )
    end
  end
end
