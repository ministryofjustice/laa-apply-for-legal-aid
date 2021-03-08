module Reports
  class MeansReportCreator < BaseReportCreator
    def call
      return if legal_aid_application.means_report

      attachment = legal_aid_application.attachments.create!(attachment_type: 'means_report',
                                                             attachment_name: 'means_report.pdf')

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: 'means_report.pdf',
        content_type: 'application/pdf'
      )
    end

    private

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
