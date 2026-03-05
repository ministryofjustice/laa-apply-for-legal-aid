module Flow
  module Steps
    module Partner
      BankStatementsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_bank_statements_path(application) },
        forward: lambda do |application|
          status = HMRC::PartnerStatusAnalyzer.call(application)
          case status
          when :partner_not_employed_no_nino, :partner_not_employed_hmrc_unavailable, :partner_not_employed_no_payments
            :partner_receives_state_benefits
          when :partner_unexpected_employment_data
            :partner_unemployed_but_hmrc_found_data_interrupts

          when :partner_employed_hmrc_unavailable
            :partner_hmrc_unavailable_interrupts
          when :partner_employed_no_nino
            :partner_no_nino_interrupts
          when :partner_unexpected_no_employment_data
            :partner_employed_but_no_hmrc_data_interrupts
          when :partner_multiple_employments
            :partner_multiple_employments_interrupts
          when :partner_single_employment
            :partner_single_employment_interrupts
          else
            raise "Unexpected hmrc status #{status.inspect}"
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
