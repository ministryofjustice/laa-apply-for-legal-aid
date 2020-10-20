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
          send_data Reports::MIS::ApplicationDetailsReport.new.run
        end
      end
    end

    def download_non_passported
      respond_to do |format|
        format.csv do
          send_data Reports::MIS::NonPassportedApplicationsReport.new.run
        end
      end
    end
  end
end
