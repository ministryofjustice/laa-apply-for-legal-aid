module Flow
  module Steps
    module Partner
      CashOutgoingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_cash_outgoing_path(application) },
        forward: lambda do |application|
                   # if the applicant did not use Truelayer and makes housing payments, or if the partner makes housing payments, then ask about housing benefit
                   if (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
                     :housing_benefits
                   else
                     :has_dependants
                   end
                 end,
        check_answers: lambda do |application|
                         if (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
                           :housing_benefits
                         else
                           :has_dependants
                         end
                       end,
      )
    end
  end
end
