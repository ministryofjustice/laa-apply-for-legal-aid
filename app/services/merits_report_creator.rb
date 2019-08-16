class MeritsReportCreator
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  attr_reader :legal_aid_application

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    legal_aid_application.merits_report.attach(
      io: StringIO.new(pdf_report),
      filename: 'merits_report.pdf',
      content_type: 'application/pdf'
    )
    legal_aid_application.generated_merits_report!
  end

  private

  def pdf_report
    WickedPdf.new.pdf_from_string(html_report)
  end

  def html_report
    Providers::MeritsReportsController.default_url_options = {
      _recall: {
        legal_aid_application_id: legal_aid_application.id
      }
    }

    Providers::MeritsReportsController.renderer.render(
      template: 'providers/merits_reports/show',
      layout: 'pdf',
      locals: {
        :@legal_aid_application => legal_aid_application
      }
    )
  end
end
