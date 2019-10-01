module CCMS
  class ObtainDocumentIdService < BaseSubmissionService
    def call
      populate_documents
      if submission.submission_document.empty?
        create_history('applicant_ref_obtained', submission.aasm_state, xml_request) if submission.submit_case!
      else
        request_document_ids
        create_history('applicant_ref_obtained', submission.aasm_state, xml_request) if submission.obtain_document_ids!
      end
    rescue CcmsError => e
      handle_ccms_failure(e, xml_request)
    end

    private

    def populate_documents
      add_statements_of_case
      add_means_report
      add_merits_report
    end

    def add_statements_of_case
      files = StatementOfCase.find_by(legal_aid_application_id: submission.legal_aid_application_id)&.original_files
      files&.each do |document|
        SubmissionDocument.create!(
          submission: submission,
          document_id: document.id,
          status: :new,
          document_type: :statement_of_case,
          ccms_document_id: nil
        )
      end
    end

    def add_means_report
      return unless submission.legal_aid_application.means_report.attachment

      SubmissionDocument.create!(
        submission: submission,
        document_id: submission.legal_aid_application.means_report.id,
        status: :new,
        document_type: :means_report,
        ccms_document_id: nil
      )
    end

    def add_merits_report
      return unless submission.legal_aid_application.merits_report.attachment

      SubmissionDocument.create!(
        submission: submission,
        document_id: submission.legal_aid_application.merits_report.id,
        status: :new,
        document_type: :merits_report,
        ccms_document_id: nil
      )
    end

    def request_document_ids
      submission.submission_document.each do |document|
        tx_id = document_id_requestor.transaction_request_id
        response = document_id_requestor.call
        document.ccms_document_id = DocumentIdResponseParser.new(tx_id, response).document_id
        document.status = :id_obtained
      rescue CcmsError => e
        document.status = :failed
        raise CcmsError, e
      end
    end

    def document_id_requestor
      @document_id_requestor ||= DocumentIdRequestor.new(submission.case_ccms_reference)
    end

    def xml_request
      @xml_request ||= document_id_requestor.formatted_xml
    end
  end
end
