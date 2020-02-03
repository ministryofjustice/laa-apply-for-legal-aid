module CCMS
  module Submitters
    class ObtainDocumentIdService < BaseSubmissionService
      def call
        populate_documents
        unless submission.submission_document.empty?
          request_document_ids
          create_history('applicant_ref_obtained', submission.aasm_state, xml_request, @response) if submission.obtain_document_ids!
        end
      rescue CcmsError => e
        handle_exception(e, xml_request)
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

      def request_document_ids
        submission.submission_document.each do |document|
          tx_id = document_id_requestor.transaction_request_id
          @response = document_id_requestor.call
          document.ccms_document_id = Parsers::DocumentIdResponseParser.new(tx_id, @response).document_id
          document.status = :id_obtained
          document.save!
          submission.save!
        rescue CcmsError => e
          document.status = :failed
          raise CcmsError, e
        end
      end

      def document_id_requestor
        @document_id_requestor ||= Requestors::DocumentIdRequestor.new(submission.case_ccms_reference, submission.legal_aid_application.provider.username)
      end

      def xml_request
        @xml_request ||= document_id_requestor.formatted_xml
      end
    end
  end
end
