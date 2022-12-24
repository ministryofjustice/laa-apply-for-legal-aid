module Reports
  class MeansReportCreator < BaseReportCreator
    def call
      return if valid_report_exists

      delete_attachment if report_attachment_exists
      attachment = legal_aid_application.attachments.create!(
        attachment_type: "means_report",
        attachment_name: "means_report.pdf",
      )

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: "means_report.pdf",
        content_type: "application/pdf",
      )

      Rails.logger.info "ReportsCreator: Means report attachment failed in #{legal_aid_application.id}" if attachment.document.download.nil?
    end

  private

    def report_type
      "means_report"
    end

    def html_report
      ensure_case_ccms_reference_exists

      Providers::MeansReportsController.default_url_options = default_url_options

      Providers::MeansReportsController.render(report_component, layout: "pdf")
    end

    def report_component
      Providers::Reports::Means.new(
        legal_aid_application:,
        manual_review_determiner:,
      )
    end

    def manual_review_determiner
      CCMS::ManualReviewDeterminer.new(legal_aid_application)
    end
  end
end
