module Reports
  class ReportsCreator
    def self.call(legal_aid_application)
      MeritsReportCreator.call(legal_aid_application)
      MeansReportCreator.call(legal_aid_application)
      BankTransactions::BankTransactionReportCreator.call(legal_aid_application) if legal_aid_application.non_passported?
      legal_aid_application.reload.generated_reports!
    end
  end
end
