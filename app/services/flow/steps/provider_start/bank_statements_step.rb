module Flow
  module Steps
    module ProviderStart
      BankStatementsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_bank_statements_path(application) },
        forward: lambda do |application|
          status = HMRC::StatusAnalyzer.call(application)
          case status
          when :applicant_not_employed_no_nino, :applicant_not_employed_hmrc_unavailable, :applicant_not_employed_no_payments
            :receives_state_benefits
          when :applicant_unexpected_employment_data
            :unemployed_but_hmrc_found_data_interrupts

          when :applicant_employed_hmrc_unavailable
            :hmrc_unavailable_interrupts
          when :applicant_employed_no_nino
            :no_nino_interrupts
          when :applicant_unexpected_no_employment_data
            :employed_but_no_hmrc_data_interrupts
          when :applicant_multiple_employments
            :multiple_employments_interrupts
          when :applicant_single_employment
            :single_employment_interrupts
          else
            raise "Unexpected hmrc status #{status.inspect}"
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
