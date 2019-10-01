module CCMS
  class UploadDocumentsService < BaseSubmissionService
    def call # rubocop:disable Metrics/AbcSize
      submission.submission_document.each do |document|
        upload_document(document)
      end

      failed_uploads = submission.submission_document.select { |document| document.status == 'failed' }

      if failed_uploads.empty?
        create_history('case_created', submission.aasm_state, nil, nil) if submission.complete!
      else
        raise CcmsError, "The following documents failed to upload: #{failed_uploads.map(&:id).join(', ')}"
      end
    rescue CcmsError => e
      handle_exception(e, nil)
    end

    private

    def upload_document(document)
      document_upload_requestor = DocumentUploadRequestor.new(submission.case_ccms_reference,
                                                              document.ccms_document_id,
                                                              Base64.strict_encode64(pdf_binary(document)))
      tx_id = document_upload_requestor.transaction_request_id
      response = document_upload_requestor.call
      update_document_status(document, tx_id, response)
      document.save!
      submission.save!
    rescue CcmsError => e
      document.status = :failed
      raise CcmsError, e
    end

    def pdf_binary(document)
      case document.document_type
      when 'statement_of_case'
        PdfFile.find_by(original_file_id: document.document_id).file.download
      when 'means_report'
        submission.legal_aid_application.means_report.attachment.download
      when 'merits_report'
        submission.legal_aid_application.merits_report.attachment.download
      end
    end

    def update_document_status(document, tx_id, response)
      document.status = if DocumentUploadResponseParser.new(tx_id, response).success?
                          :uploaded
                        else
                          :failed
                        end
    end
  end
end
