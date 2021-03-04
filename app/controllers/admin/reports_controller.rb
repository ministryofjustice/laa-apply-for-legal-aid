module Admin
  class ReportsController < AdminBaseController
    include Pagy::Backend

    DEFAULT_PAGE_SIZE = 10

    def index
      reports
    end

    def create
      reports
      reports_types_creator
      render :index
    end

    def download_custom_report
      send_file Rails.root.join('tmp/custom-apply-ccms-report.csv')
    end

    def download_submitted
      expires_now
      respond_to do |format|
        format.csv do
          send_data mis_data, filename: "submitted_applications_#{timestamp}.csv", content_type: 'text/csv'
        end
      end
    end

    def download_non_passported
      expires_now
      respond_to do |format|
        format.csv do
          send_data mis_data, filename: "non_passported_#{timestamp}.csv", type: :csv, content_type: 'text/csv'
        end
      end
    end

    def timestamp
      Time.current.strftime('%FT%T')
    end

    private

    def reports_types_creator
      @reports_types_creator ||= Reports::ReportsTypesCreator.call(form_params)
    end

    def mis_data
      @mis_data ||= Reports::MIS::NonPassportedApplicationsReport.new.run
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
