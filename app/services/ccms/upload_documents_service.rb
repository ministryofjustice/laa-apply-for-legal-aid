module CCMS
  class UploadDocumentsService < BaseSubmissionService
    def call
      submission.documents.each do |document|
        upload_document(document)
      end

      failed_uploads = submission.documents.select { |document| document[:status] == :failed }

      if failed_uploads.empty?
        create_history('case_created', submission.aasm_state) if submission.complete!
      else
        handle_failure("#{failed_uploads} failed to upload to CCMS")
      end
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def upload_document(document)
      pdf_file = PdfFile.find_by(original_file_id: document[:id])
      document_upload_requestor = DocumentUploadRequestor.new(submission.case_ccms_reference, document[:ccms_document_id], Base64.strict_encode64(pdf_file.file.download))
      tx_id = document_upload_requestor.transaction_request_id
      response = document_upload_requestor.call
      update_document_status(document, tx_id, response)
    rescue CcmsError => e
      document[:status] = :failed
      raise CcmsError, e
    end

    def update_document_status(document, tx_id, response)
      document[:status] = if DocumentUploadResponseParser.new(tx_id, response).success?
                            :uploaded
                          else
                            :failed
                          end
    end
  end
end
