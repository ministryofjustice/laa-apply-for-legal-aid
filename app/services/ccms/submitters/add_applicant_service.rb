module CCMS
  module Submitters
    class AddApplicantService < BaseSubmissionService
      def call # rubocop:disable Metrics/AbcSize
        if applicant_add_response_parser.success?
          submission.applicant_add_transaction_id = applicant_add_requestor.transaction_request_id
          submission.save!
          create_history('case_ref_obtained', submission.aasm_state, xml_request, response) if submission.submit_applicant!
        else
          handle_unsuccessful_response(xml_request, response)
        end
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, xml_request)
      end

      private

      def applicant_add_requestor
        @applicant_add_requestor ||= CCMS::Requestors::ApplicantAddRequestor.new(legal_aid_application.applicant, legal_aid_application.provider.username)
      end

      def applicant_add_response_parser
        @applicant_add_response_parser ||= CCMS::Parsers::ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
      end

      def response
        @response ||= applicant_add_requestor.call
      end

      def legal_aid_application
        submission.legal_aid_application
      end

      def xml_request
        @xml_request ||= applicant_add_requestor.formatted_xml
      end
    end
  end
end
