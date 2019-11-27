module Reports
  class ReportsCreator
    def self.call(legal_aid_application)
      MeritsReportCreator.call(legal_aid_application)
      MeansReportCreator.call(legal_aid_application)
      legal_aid_application.reload.generated_reports!
    end
  end
end
