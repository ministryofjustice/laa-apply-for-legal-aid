module Flow
  module Steps
    module Partner
      EmployedStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_employed_index_path(application) },
        forward: lambda do |application|
          if application.partner.self_employed? || application.partner.armed_forces?
            :partner_use_ccms_employment
          elsif application.partner.employed? && !application.partner.has_national_insurance_number?
            :partner_full_employment_details
          else
            :partner_bank_statements
          end
        end,
      )
    end
  end
end
