module Reports
  class MeansReportCreator < BaseReportCreator
    def call
      return if valid_means_report_exists

      delete_attachment if means_report_attachment_exists
      attachment = legal_aid_application.attachments.create!(attachment_type: 'means_report',
                                                             attachment_name: 'means_report.pdf')

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: 'means_report.pdf',
        content_type: 'application/pdf'
      )

      Rails.logger.info "ReportsCreator: Means report attachment failed in #{legal_aid_application.id}" if attachment.document.download.nil?
    end

    private

    def delete_attachment
      legal_aid_application.means_report.destroy!
      legal_aid_application.reload
    end

    def valid_means_report_exists
      if means_report_document_exists
        Rails.logger.info "ReportsCreator: Means report already exists for #{legal_aid_application.id} and is downloadable"
      elsif means_report_attachment_exists
        Rails.logger.info "ReportsCreator: Means report already exists for #{legal_aid_application.id}"
      end
      means_report_attachment_exists && means_report_document_exists
    end

    def means_report_attachment_exists
      @means_report_attachment_exists ||= legal_aid_application&.means_report
    end

    def means_report_document_exists
      @means_report_document_exists ||= legal_aid_application&.means_report&.document&.present?
    end

    def html_report
      ensure_case_ccms_reference_exists

      Providers::MeansReportsController.default_url_options = default_url_options

      Providers::MeansReportsController.renderer.render(
        template: 'providers/means_reports/show',
        layout: 'pdf',
        locals: {
          :@legal_aid_application => legal_aid_application,
          :@cfe_result => legal_aid_application.cfe_result,
          :@manual_review_determiner => CCMS::ManualReviewDeterminer.new(legal_aid_application)
        }
      )
    end
  end
end
