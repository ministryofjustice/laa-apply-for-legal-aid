module CCMS
  module Submitters
    class ObtainDocumentIdService < BaseSubmissionService
      def call
        return unless populate_documents

        submission.submission_documents.each do |document|
          request_document_id(document)
        end
        raise CcmsError, "Failed to obtain document ids for: #{failed_requesting_ids}" if failed_requesting_ids.present?

        submission.obtain_document_ids!
      rescue CcmsError => e
        handle_exception(e, nil)
      end

      private

      def pdf_attachments
        @pdf_attachments ||= attachments.reject { |a| a.attachment_type == 'statement_of_case' }
      end

      def attachments
        legal_aid_application.attachments.all
      end

      def legal_aid_application
        @legal_aid_application ||= submission.legal_aid_application
      end

      def populate_documents
        pdf_attachments.each do |attachment|
          SubmissionDocument.create!(
            submission: submission,
            attachment_id: attachment.id,
            status: :new,
            document_type: attachment.attachment_type,
            ccms_document_id: nil
          )
        end
      end

      def request_document_id(document)
        document_id_requestor = document_id_requestor(document.document_type)
        response = update_document_and_return_response(document, document_id_requestor)
        document.save!
        create_history('applicant_ref_obtained', 'document_ids_obtained', document_id_requestor.formatted_xml, response) if submission.save!
      rescue CcmsError => e
        document.status = :failed
        document.save!
        create_ccms_failure_history('applicant_ref_obtained', e, document_id_requestor.formatted_xml)
      end

      def ccms_document_id(dir)
        Parsers::DocumentIdResponseParser.new(dir.transaction_request_id, dir.call).document_id
      end

      def document_id_requestor(document_type)
        Requestors::DocumentIdRequestor.new(submission.case_ccms_reference, submission.legal_aid_application.provider.username, document_type)
      end

      def update_document_and_return_response(document, document_id_requestor)
        document.ccms_document_id = ccms_document_id(document_id_requestor)
        document.status = :id_obtained
        document_id_requestor.call
      end

      def failed_requesting_ids
        @failed_requesting_ids ||= submission.submission_documents.select { |document| document.status == 'failed' }&.map(&:id)&.join(', ')
      end
    end
  end
end
