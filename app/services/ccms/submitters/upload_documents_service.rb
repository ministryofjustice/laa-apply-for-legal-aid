module CCMS
  module Submitters
    class UploadDocumentsService < BaseSubmissionService
      def call # rubocop:disable Metrics/AbcSize
        submission.submission_document.each do |submission_document|
          upload_document(submission_document)
        end

        failed_uploads = submission.submission_document.select { |document| document.status == 'failed' }

        raise CcmsError, "The following documents failed to upload: #{failed_uploads.map(&:id).join(', ')}" if failed_uploads.present?

        create_history('case_created', submission.aasm_state, nil, nil) if submission.complete!
      rescue CcmsError => e
        handle_exception(e, nil)
      end

      private

      def upload_document(submission_document)
        document_upload_requestor = CCMS::Requestors::DocumentUploadRequestor.new(submission.case_ccms_reference,
                                                                                  submission_document.ccms_document_id,
                                                                                  Base64.strict_encode64(pdf_binary(submission_document)),
                                                                                  submission.legal_aid_application.provider.username)
        tx_id = document_upload_requestor.transaction_request_id
        response = document_upload_requestor.call
        update_document_status(submission_document, tx_id, response)
        submission_document.save!
        submission.save!
      rescue CcmsError => e
        submission_document.status = :failed
        raise CcmsError, e
      end

      def pdf_binary(submission_document)
        Attachment.find(submission_document.attachment_id).document.download
      end

      def update_document_status(document, tx_id, response)
        document.status = if CCMS::Parsers::DocumentUploadResponseParser.new(tx_id, response).success?
                            :uploaded
                          else
                            :failed
                          end
      end
    end
  end
end
