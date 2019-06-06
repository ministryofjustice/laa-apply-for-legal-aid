module CCMS
  class UploadDocumentsService < BaseSubmissionService
    def call
      submission.documents.each do |key, _value|
        upload_document(key)
      end

      failed_uploads = submission.documents.select { |_key, value| value == :failed }

      if failed_uploads.empty?
        create_history('document_ids_obtained', submission.aasm_state) if submission.complete!
      else
        handle_failure("#{failed_uploads.keys} failed to upload to CCMS")
      end
    rescue CcmsError, StandardError => e # TODO: Replace `StandardError` with list of known expected errors
      handle_failure(e)
    end

    private

    def upload_document(key)
      pdf_file = PdfFile.find_by(original_file_id: key)
      document_upload_requestor = DocumentUploadRequestor.new(submission.case_ccms_reference, pdf_file.ccms_document_id, Base64.strict_encode64(pdf_file.file.download))
      tx_id = document_upload_requestor.transaction_request_id
      response = document_upload_requestor.call
      update_document_status(key, tx_id, response)
    rescue CcmsError, StandardError => e # TODO: Replace `StandardError` with list of known expected errors
      submission.documents[key] = :failed
      raise CcmsError, e
    end

    def update_document_status(key, tx_id, response)
      submission.documents[key] = if DocumentUploadResponseParser.new(tx_id, response).success?
                                    :uploaded
                                  else
                                    :failed
                                  end
    end
  end
end
