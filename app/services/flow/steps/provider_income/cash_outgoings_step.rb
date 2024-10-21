module Flow
  module Steps
    module ProviderIncome
      CashOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_cash_outgoing_path(application) },
        forward: lambda do |application|
          unless application.client_uploading_bank_statements?
            if application.income_types?
              return :income_summary
            elsif application.outgoing_types?
              return :outgoings_summary
            end
          end

          if application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          elsif application.housing_payments_for?("Applicant")
            :housing_benefits
          else
            :has_dependants
          end
        end,
        check_answers: lambda do |application|
          return :outgoings_summary if application.outgoing_types? && !application.client_uploading_bank_statements?
          return :housing_benefit if application.housing_payments_for?("Applicant") || application.housing_payments_for?("Partner")

          :check_income_answers
        end,
      )
    end
  end
end
