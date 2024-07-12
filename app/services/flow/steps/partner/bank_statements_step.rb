module Flow
  module Steps
    module Partner
      BankStatementsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_bank_statements_path(application) },
        forward: lambda do |application|
          status = HMRC::PartnerStatusAnalyzer.call(application)
          case status
          when :partner_multiple_employments, :partner_no_hmrc_data
            :partner_full_employment_details
          when :partner_single_employment
            :partner_employment_incomes
          when :partner_unexpected_employment_data
            :partner_unexpected_employment_incomes
          when :partner_not_employed
            :partner_receives_state_benefits
          else
            raise "Unexpected hmrc status #{status.inspect}"
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
