module CCMS
  module Submitters
    class ObtainDocumentIdService < BaseSubmissionService
      def call
        submission.submission_documents.destroy_all
        return unless populate_documents

        submission.reload.submission_documents.each do |document|
          request_document_id(document)
        end
        raise CCMSError, "Failed to obtain document ids for: #{failed_requesting_ids}" if failed_requesting_ids.present?

        submission.obtain_document_ids!
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, nil)
        raise
      end

    private

      def submittable_attachments
        @submittable_attachments ||= attachments.select { |a| DocumentCategory.submittable_category_names.include?(a.attachment_type) }
      end

      def attachments
        legal_aid_application.attachments.all
      end

      def legal_aid_application
        @legal_aid_application ||= submission.legal_aid_application
      end

      def populate_documents
        submittable_attachments.each do |attachment|
          SubmissionDocument.create!(
            submission:,
            attachment_id: attachment.id,
            status: :new,
            document_type: attachment.attachment_type,
            ccms_document_id: nil,
          )
        end
      end

      def request_document_id(document)
        document_id_requestor = document_id_requestor(document.document_type)
        response = update_document_and_return_response(document, document_id_requestor)
        document.save!
        create_history("applicant_ref_obtained", "document_ids_obtained", document_id_requestor.formatted_xml, response) if submission.save!
      rescue *CCMS_SUBMISSION_ERRORS => e
        document.status = :failed
        document.save!
        handle_exception(e, document_id_requestor.formatted_xml)
        raise
      end

      def ccms_document_id(transaction_request_id, response)
        Parsers::DocumentIdResponseParser.new(transaction_request_id, response).document_id
      end

      def document_id_requestor(document_type)
        Requestors::DocumentIdRequestor.new(submission.case_ccms_reference, submission.legal_aid_application.merits_submitted_by.username, document_type)
      end

      def update_document_and_return_response(document, document_id_requestor)
        response = document_id_requestor.call
        document.ccms_document_id = ccms_document_id(document_id_requestor.transaction_request_id, response)
        document.status = :id_obtained
        response
      end

      def failed_requesting_ids
        @failed_requesting_ids ||= submission.submission_documents.select { |document| document.status == "failed" }&.map(&:id)&.join(", ")
      end
    end
  end
end
