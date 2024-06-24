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
          send_data data, filename: "application_details_#{timestamp}.csv", content_type: "text/csv"
        end
      end
    end

    def download_provider_emails_report
      expires_now
      respond_to do |format|
        format.csv do
          tempfile = Tempfile.new("provider_emails_report")
          CSV.open(tempfile, "w", write_headers: true, headers: %w[email last_active]) do |csv|
            Provider.order(updated_at: :desc).each do |provider|
              csv << [provider.email, provider.updated_at]
            end
          end
          send_data tempfile.read, filename: "provider_emails_#{timestamp}.csv", content_type: "text/csv"
        end
      end
    end

    def download_user_feedbacks_report
      expires_now
      respond_to do |format|
        format.csv do
          tempfile = Tempfile.new("user_feedbacks_report")
          CSV.open(tempfile, "w", write_headers: true, headers: %w[updated_at created_at source satisfaction difficulty improvement_suggestion]) do |csv|
            Feedback.order(created_at: :desc).each do |feedback|
              csv << [feedback.updated_at, feedback.created_at, feedback.source, feedback.satisfaction, feedback.difficulty, feedback.improvement_suggestion]
            end
          end
          send_data tempfile.read, filename: "user_feedbacks_#{timestamp}.csv", content_type: "text/csv"
        end
      end
    end

    def timestamp
      Time.current.strftime("%FT%T")
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
          report_title: "Application Details report",
          path: :admin_application_details_csv_path,
          path_text: "Download CSV",
        },
        provider_download: {
          report_title: "Provider email",
          path: :admin_provider_emails_csv_path,
          path_text: "Download CSV",
        },
        user_feedback_download: {
          report_title: "User feedback",
          path: :admin_user_feedbacks_csv_path,
          path_text: "Download CSV",
        },
      }
    end
  end
end
