module Reports
  class MeritsReportCreator < BaseReportCreator
    def call
      return if valid_report_exists

      delete_attachment if report_attachment_exists
      attachment = legal_aid_application.attachments.create!(attachment_type: "merits_report",
                                                             attachment_name: "merits_report.pdf")

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: "merits_report.pdf",
        content_type: "application/pdf",
      )

      Rails.logger.info "ReportsCreator: Merits report attachment failed in #{legal_aid_application.id}" if attachment.document.download.nil?
    end

  private

    def report_type
      "merits_report"
    end

    def html_report
      ensure_case_ccms_reference_exists

      Providers::MeritsReportsController.default_url_options = default_url_options

      Providers::MeritsReportsController.renderer.render(
        template: "providers/merits_reports/show",
        layout: "pdf",
        locals: {
          legal_aid_application:,
        },
      )
    end
  end
end
