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
          CSV.open(tempfile, "w", write_headers: true, headers: %w[date time source satisfaction difficulty improvement_suggestion]) do |csv|
            Feedback.order(created_at: :asc).each do |feedback|
              feedback_date = feedback.created_at.strftime("%Y-%m-%d")
              feedback_time = feedback.created_at.strftime("%H:%M")
              csv << [feedback_date, feedback_time, feedback.source, feedback.satisfaction, feedback.difficulty, feedback.improvement_suggestion]
            end
          end
          send_data tempfile.read, filename: "user_feedback_report_#{timestamp}.csv", content_type: "text/csv"
        end
      end
    end

    def download_application_digest_report
      expires_now
      respond_to do |format|
        format.csv do
          tempfile = Tempfile.new("application_digest_report")
          headers = ApplicationDigest.first.attributes.keys - %w[id created_at updated_at]

          CSV.open(tempfile, "w", write_headers: true, headers: headers) do |csv|
            ApplicationDigest.order(created_at: :desc).each do |record|
              csv << record.attributes.slice(*headers).values
            end
          end

          send_data tempfile.read, filename: "application_digest_#{timestamp}.csv", content_type: "text/csv"
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
          report_title: "Application Details report ",
          report_link: { href: "https://dsdmoj.atlassian.net/wiki/x/JwBOKQE", text: "About this report (opens in new tab)", class: "govuk-link govuk-link--no-visited-state", rel: "noreferrer noopener", target: "_blank" },
          path: :admin_application_details_csv_path,
          path_text: "Download <span class=\"govuk-visually-hidden\">application details</span>CSV".html_safe,
        },
        application_digest_download: {
          report_title: "Application Digest report",
          report_link: nil,
          path: :admin_application_digest_csv_path,
          path_text: "Download <span class=\"govuk-visually-hidden\">application digest</span>CSV".html_safe,
        },
        provider_download: {
          report_title: "Provider email report",
          report_link: nil,
          path: :admin_provider_emails_csv_path,
          path_text: "Download <span class=\"govuk-visually-hidden\">provider emails</span>CSV".html_safe,
        },
        user_feedback_download: {
          report_title: "User feedback report",
          report_link: nil,
          path: :admin_user_feedbacks_csv_path,
          path_text: "Download <span class=\"govuk-visually-hidden\">user feedback</span>CSV".html_safe,
        },
      }
    end
  end
end
