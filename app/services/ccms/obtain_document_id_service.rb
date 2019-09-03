module CCMS
  class ObtainDocumentIdService < BaseSubmissionService
    def call
      populate_documents
      if submission.documents.empty?
        create_history('applicant_ref_obtained', submission.aasm_state) if submission.submit_case!
      else
        request_document_ids
        create_history('applicant_ref_obtained', submission.aasm_state) if submission.obtain_document_ids!
      end
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def populate_documents
      submission.documents = []
      files = StatementOfCase.find_by(legal_aid_application_id: submission.legal_aid_application_id)&.original_files
      files&.each do |document|
        submission.documents << { id: document.id, status: :new, type: :statement_of_case, ccms_document_id: nil }
      end
    end

    def request_document_ids
      submission.documents.each do |document|
        tx_id = document_id_requestor.transaction_request_id
        response = document_id_requestor.call
        document[:ccms_document_id] = DocumentIdResponseParser.new(tx_id, response).document_id
        document[:status] = :id_obtained
      rescue CcmsError => e
        document[:status] = :failed
        raise CcmsError, e
      end
    end

    def document_id_requestor
      @document_id_requestor ||= DocumentIdRequestor.new(submission.case_ccms_reference)
    end
  end
end
