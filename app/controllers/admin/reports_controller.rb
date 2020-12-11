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
      expires_now
      respond_to do |format|
        format.csv do
          data = Reports::MIS::ApplicationDetailsReport.new.run
          send_data data, filename: "submitted_applications_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def download_non_passported
      expires_now
      data = Reports::MIS::NonPassportedApplicationsReport.new.run
      Raven.capture_message "Downloading non passported\n#{data}"
      respond_to do |format|
        format.csv do
          send_data data, filename: "non_passported_#{timestamp}.csv", type: :csv, content_type: 'text/csv'
        end
      end
    end

    # :nocov:
    def render_non_passported
      expires_now
      response.headers['Content-Disposition'] = %(attachment; filename="rendered_non_passported_#{timestamp}.csv")
      response.headers['Content-Type'] = 'text/csv'
      data = Reports::MIS::NonPassportedApplicationsReport.new.run
      render plain: data
    end
    # :nocov:

    def timestamp
      Time.now.strftime('%FT%T')
    end
  end
end
