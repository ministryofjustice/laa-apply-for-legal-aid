module Flow
  module Steps
    module ProviderIncome
      IdentifyTypesOfOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_identify_types_of_outgoing_path(application) },
        forward: lambda do |application|
          if application.outgoing_types?
            :cash_outgoings
          elsif application.income_types? && !application.uploading_bank_statements?
            :income_summary
          elsif application.applicant.has_partner_with_no_contrary_interest?
            :partner_about_financial_means
          else
            :has_dependants
          end
        end,
        check_answers: lambda do |application|
          application.outgoing_types? ? :cash_outgoings : :check_income_answers
        end,
      )
    end
  end
end
