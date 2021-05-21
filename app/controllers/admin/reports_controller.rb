module Admin
  class ReportsController < AdminBaseController
    include Pagy::Backend

    DEFAULT_PAGE_SIZE = 10

    def index
      reports
    end

    def create
      reports
      if reports_types_creator.valid?
        download_custom_report
      else
        render :index
      end
    end

    def download_submitted
      expires_now
      respond_to do |format|
        format.csv do
          send_data submitted_applications_report, filename: "submitted_applications_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def download_non_passported
      expires_now
      respond_to do |format|
        format.csv do
          send_data non_passported_applications_report, filename: "non_passported_#{timestamp}.csv", type: :csv, content_type: 'text/csv'
        end
      end
    end

    def timestamp
      Time.current.strftime('%FT%T')
    end

    private

    def submitted_applications_report
      attachment = admin_report.submitted_applications.attachment
      attachment.blob.download
    end

    def non_passported_applications_report
      attachment = admin_report.non_passported_applications.attachment
      attachment.blob.download
    end

    def admin_report
      @admin_report ||= AdminReport.first
    end

    def download_custom_report
      expires_now
      data = reports_types_creator.generate_csv
      send_data data, filename: "custom_apply_ccms_report_#{timestamp}.csv", type: :csv, content_type: 'text/csv'
    end

    def reports_types_creator
      @reports_types_creator ||= Reports::ReportsTypesCreator.call(form_params)
    end

    def reports
      @reports ||= {
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

    def form_params
      convert_date_params(params[:reports_reports_types_creator] || params)
    end
  end
end
