module Reports
  class BaseReportCreator
    include GroverOptionable

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

  private

    def pdf_report
      Grover.new(html_report, style_tag_options:).to_pdf
    end

    def ensure_case_ccms_reference_exists
      return if legal_aid_application.case_ccms_reference

      legal_aid_application.create_ccms_submission unless legal_aid_application.ccms_submission
      process_ccms_submission
    end

    def process_ccms_submission
      legal_aid_application.ccms_submission.process!
    end

    def html_report; end

    def default_url_options
      {
        _recall: {
          legal_aid_application_id: legal_aid_application.id,
        },
      }
    end

    def delete_attachment
      legal_aid_application.send(report_type).destroy!
      legal_aid_application.reload
    end

    def valid_report_exists
      if report_document_exists
        Rails.logger.info "ReportsCreator: #{report_type.humanize} already exists for #{legal_aid_application.id} and is downloadable"
      elsif report_attachment_exists
        Rails.logger.info "ReportsCreator: #{report_type.humanize} already exists for #{legal_aid_application.id}"
      end
      report_attachment_exists && report_document_exists
    end

    def report_attachment_exists
      @report_attachment_exists ||= legal_aid_application&.send(report_type)
    end

    def report_document_exists
      @report_document_exists ||= legal_aid_application&.send(report_type)&.document&.present?
    end
  end
end
