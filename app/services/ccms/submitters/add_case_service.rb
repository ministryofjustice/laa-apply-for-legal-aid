module CCMS
  module Submitters
    class AddCaseService < BaseSubmissionService
      def self.call(submission, options)
        new(submission).call(options)
      end

      def call(options = {}) # rubocop:disable Metrics/AbcSize
        @options = options
        if case_add_response_parser.success?
          submission.case_add_transaction_id = case_add_requestor.transaction_request_id
          submission.save!
          create_history(from_state?, submission.aasm_state, xml_request, response) if submission.submit_case!
        else
          handle_unsuccessful_response(xml_request, response)
        end
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, xml_request)
      end

      private

      def from_state?
        submission.submission_documents.empty? ? 'applicant_ref_obtained' : 'document_ids_obtained'
      end

      def case_add_requestor
        @case_add_requestor ||= CaseAddRequestorFactory.call(submission, @options)
      end

      def case_add_response_parser
        @case_add_response_parser ||= CCMS::Parsers::CaseAddResponseParser.new(case_add_requestor.transaction_request_id, response)
      end

      def response
        @response ||= case_add_requestor.call
      end

      def xml_request
        @xml_request ||= case_add_requestor.formatted_xml
      end
    end
  end
end
