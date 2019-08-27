module Reports
  class MeansReportCreator
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      legal_aid_application.means_report.attach(
        io: StringIO.new(pdf_report),
        filename: 'means_report.pdf',
        content_type: 'application/pdf'
      )
    end

    private

    def pdf_report
      WickedPdf.new.pdf_from_string(html_report)
    end

    def html_report
      Providers::MeansReportsController.default_url_options = {
        _recall: {
          legal_aid_application_id: legal_aid_application.id
        }
      }

      Providers::MeansReportsController.renderer.render(
        template: 'providers/means_reports/show',
        layout: 'pdf',
        locals: {
          :@legal_aid_application => legal_aid_application
        }
      )
    end
  end
end
