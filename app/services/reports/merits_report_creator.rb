module Reports
  class MeritsReportCreator < BaseReportCreator
    def call
      return if valid_merits_report_exists

      attachment = legal_aid_application.attachments.create!(attachment_type: 'merits_report',
                                                             attachment_name: 'merits_report.pdf')

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: 'merits_report.pdf',
        content_type: 'application/pdf'
      )

      Rails.logger.info "ReportsCreator: Merits report attachment failed in #{legal_aid_application.id}" if attachment.document.download.nil?
    end

    private

    def valid_merits_report_exists
      if merits_report_document_exists
        Rails.logger.info "ReportsCreator: Merits report already exists for #{legal_aid_application.id} and is downloadable"
      elsif merits_report_attachment_exists
        Rails.logger.info "ReportsCreator: Merits report already exists for #{legal_aid_application.id}"
      end
      merits_report_attachment_exists && merits_report_document_exists
    end

    def merits_report_attachment_exists
      @merits_report_attachment_exists ||= legal_aid_application&.merits_report
    end

    def merits_report_document_exists
      @merits_report_document_exists ||= legal_aid_application&.merits_report&.document&.present?
    end

    def html_report
      ensure_case_ccms_reference_exists

      Providers::MeritsReportsController.default_url_options = default_url_options

      Providers::MeritsReportsController.renderer.render(
        template: 'providers/merits_reports/show',
        layout: 'pdf',
        locals: {
          :@legal_aid_application => legal_aid_application,
          :@application_proceeding_type => legal_aid_application.lead_application_proceeding_type
        }
      )
    end
  end
end
