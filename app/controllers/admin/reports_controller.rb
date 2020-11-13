module Admin
  class ReportsController < AdminBaseController
    include Pagy::Backend

    DEFAULT_PAGE_SIZE = 10

    def index
      @reports = {
        csv_download: {
          report_title: 'Download CSV of all submitted applications',
          path: :admin_reports_submitted_csv_path,
          path_text: 'Download CSV'
        },
        non_passported_applications: {
          report_title: 'Non passported applications',
          path: :admin_reports_non_passported_csv_path,
          path_text: 'Download CSV'
        }
      }
    end

    def download_submitted
      respond_to do |format|
        format.csv do
          data = Reports::MIS::ApplicationDetailsReport.new.run
          send_data data, filename: "submitted_applications_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def download_non_passported
      respond_to do |format|
        format.csv do
          data = Reports::MIS::NonPassportedApplicationsReport.new.run
          send_data data, filename: "non_passported_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def timestamp
      Time.now.strftime('%FT%T')
    end
  end
end
