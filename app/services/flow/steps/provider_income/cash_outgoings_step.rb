module Flow
  module Steps
    module ProviderIncome
      CashOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_cash_outgoing_path(application) },
        forward: lambda do |application|
          unless application.uploading_bank_statements?
            if application.income_types?
              return :income_summary
            elsif application.outgoing_types?
              return :outgoings_summary
            end
          end
          if application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          elsif application.uploading_bank_statements? && application.housing_payments_for?("Applicant")
            :housing_benefits
          else
            :has_dependants
          end
        end,
        check_answers: lambda do |application|
          if application.uploading_bank_statements?
            application.housing_payments_for?("Applicant") ? :housing_benefits : :check_income_answers
          else
            :outgoings_summary
          end
        end,
      )
    end
  end
end
