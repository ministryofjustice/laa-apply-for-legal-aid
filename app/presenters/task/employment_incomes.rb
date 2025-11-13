module Task
  class EmploymentIncomes < Base
    def path
      if application.provider_received_citizen_consent.nil?
        Flow::Steps::ProviderStart::OpenBankingConsentsStep.path.call(application)
      elsif application.provider_received_citizen_consent == false && application.attachments.bank_statement_evidence.empty?
        Flow::Steps::ProviderStart::BankStatementsStep.path.call(application)
      else
        status = HMRC::StatusAnalyzer.call(application)
        case status
        when :applicant_multiple_employments, :applicant_no_hmrc_data
          Flow::Steps::ProviderIncome::FullEmploymentDetailsStep.path.call(application)
        when :applicant_single_employment
          Flow::Steps::ProviderIncome::EmploymentIncomesStep.path.call(application)
        when :applicant_unexpected_employment_data
          Flow::Steps::ProviderIncome::UnexpectedEmploymentIncomesStep.path.call(application)
        else
          raise "Unexpected hmrc status #{status.inspect}"
        end
      end
    end
  end
end
