module CCMS
  class ObtainDocumentIdService < BaseSubmissionService
    def call
      populate_documents
      if submission.documents.empty?
        create_history('case_created', submission.aasm_state) if submission.complete!
      else
        request_document_ids
        create_history('case_created', submission.aasm_state) if submission.obtain_document_ids!
      end
    rescue CcmsError, StandardError => e # TODO: Replace `StandardError` with list of known expected errors
      handle_failure(e)
    end

    private

    def populate_documents
      files = StatementOfCase.find_by(legal_aid_application_id: submission.legal_aid_application_id)&.original_files
      files&.each { |document| submission.documents[document.id] = :new }
    end

    def request_document_ids
      submission.documents.each do |key, _value|
        tx_id = document_id_requestor.transaction_request_id
        response = document_id_requestor.call
        PdfFile.update(original_file_id: key, ccms_document_id: DocumentIdResponseParser.new(tx_id, response).document_id)
        submission.documents[key] = :id_obtained
      rescue CcmsError, StandardError => e # TODO: Replace `StandardError` with list of known expected errors
        submission.documents[key] = :failed
        raise CcmsError, e
      end
    end

    def document_id_requestor
      @document_id_requestor ||= DocumentIdRequestor.new(submission.case_ccms_reference)
    end
  end
end
