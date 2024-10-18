module Flow
  module Steps
    module Partner
      RegularOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_regular_outgoings_path(application) },
        forward: lambda do |application|
          if application.partner_outgoing_types?
            :partner_cash_outgoings
          elsif (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
            :housing_benefits
          else
            :has_dependants
          end
        end,
        check_answers: lambda do |application|
          if application.partner_outgoing_types?
            :partner_cash_outgoings
          elsif (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
            :housing_benefits
          else
            :check_income_answers
          end
        end,
      )
    end
  end
end
