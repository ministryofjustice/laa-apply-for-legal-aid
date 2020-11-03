module CCMS
  module Submitters
    class ObtainCaseReferenceService < BaseSubmissionService
      def call
        submission.case_ccms_reference = reference_id
        submission.save!
        create_history(:initialised, submission.aasm_state, xml_request, response) if submission.obtain_case_ref!
      rescue CCMSError => e
        handle_exception(e, xml_request)
      end

      def reference_id
        CCMS::Parsers::ReferenceDataResponseParser.new(transaction_request_id, response).reference_id
      end

      def response
        @response ||= reference_data_requestor.call
      end

      def transaction_request_id
        reference_data_requestor.transaction_request_id
      end

      private

      def reference_data_requestor
        @reference_data_requestor ||= CCMS::Requestors::ReferenceDataRequestor.new(submission.legal_aid_application.provider.username)
      end

      def xml_request
        reference_data_requestor.request_xml
      end
    end
  end
end
