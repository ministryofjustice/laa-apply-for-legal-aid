module Flow
  module Steps
    module ProviderStart
      BankStatementsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_bank_statements_path(application) },
        forward: lambda do |application|
          status = HMRC::StatusAnalyzer.call(application)
          case status
          when :applicant_multiple_employments, :applicant_no_hmrc_data
            :full_employment_details
          when :applicant_single_employment
            :employment_incomes
          when :applicant_unexpected_employment_data
            :unexpected_employment_incomes
          when :applicant_not_employed
            :receives_state_benefits
          else
            raise "Unexpected hmrc status #{status.inspect}"
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
