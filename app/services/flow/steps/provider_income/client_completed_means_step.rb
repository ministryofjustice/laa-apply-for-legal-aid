module Flow
  module Steps
    module ProviderIncome
      ClientCompletedMeansStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_completed_means_path(application) },
        forward: lambda do |application|
          status = HMRC::StatusAnalyzer.call(application)
          case status
          when :applicant_not_employed_no_nino, :applicant_not_employed_hmrc_unavailable, :applicant_not_employed_no_payments
            application.uploading_bank_statements? ? :receives_state_benefits : :identify_types_of_incomes
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
      )
    end
  end
end
