module Admin
  class ReportsController < AdminBaseController
    def index
      reports
    end

    def download_application_details_report
      expires_now
      respond_to do |format|
        format.csv do
          data = application_details_report || Reports::MIS::ApplicationDetailsReport.new.run
          send_data data, filename: "application_details_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def timestamp
      Time.current.strftime('%FT%T')
    end

  private

    def application_details_report
      return unless admin_report

      attachment = admin_report.application_details_report.attachment
      attachment.blob.download
    end

    def admin_report
      @admin_report ||= AdminReport.first
    end

    def reports
      @reports ||= {
        csv_download: {
          report_title: 'Application Details report',
          path: :admin_application_details_csv_path,
          path_text: 'Download CSV',
        },
      }
    end
  end
end
