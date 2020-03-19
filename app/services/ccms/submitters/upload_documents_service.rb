module CCMS
  module Submitters
    class UploadDocumentsService < BaseSubmissionService
      def call # rubocop:disable Metrics/AbcSize
        puts ">>>>>>>>>>>> CALLING UPLOAD DOCUMENT SERVICE #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
        submission.submission_documents.each do |submission_document|
          puts ">>>>>>>>>>>> processing documnt #{submission_document.document_type} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
          upload_document(submission_document)
        end

        failed_uploads = submission.submission_documents.select { |document| document.status == 'failed' }

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
        puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
        response = document_upload_requestor.call
        puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
        update_document_status(submission_document, tx_id, response)
        puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
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
        puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
        document.status = if CCMS::Parsers::DocumentUploadResponseParser.new(tx_id, response).success?
                            puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
                            :uploaded
                          else
                            puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
                            :failed
                          end
      end
    end
  end
end
