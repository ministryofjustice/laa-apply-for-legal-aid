module Flow
  module Steps
    module ProviderIncome
      ClientCompletedMeansStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_completed_means_path(application) },
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
            if application.uploading_bank_statements?
              :receives_state_benefits
            else
              :identify_types_of_incomes
            end
          else
            raise "Unexpected hmrc status #{status.inspect}"
          end
        end,
      )
    end
  end
end
