module CCMS
  module Submitters
    class ObtainApplicantReferenceService < BaseSubmissionService
      def call
        tx_id = applicant_search_requestor.transaction_request_id
        parser = CCMS::Parsers::ApplicantSearchResponseParser.new(tx_id, response, legal_aid_application.applicant)
        process_records(parser)
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, xml_request)
        raise
      end

      def response
        @response ||= applicant_search_requestor.call
      end

    private

      def applicant_search_requestor
        @applicant_search_requestor ||= CCMS::Requestors::ApplicantSearchRequestor.new(legal_aid_application.applicant, legal_aid_application.merits_submitted_by.username)
      end

      def process_records(parser)
        applicant_ccms_reference = parser.applicant_ccms_reference
        if applicant_ccms_reference.nil?
          history = create_history(:case_ref_obtained, submission.aasm_state, xml_request, response)
          log_message("SubmissionHistory: #{history.id}: Creating new applicant in CCMS")
          CCMS::Submitters::AddApplicantService.new(submission).call
        else
          submission.applicant_ccms_reference = applicant_ccms_reference
          submission.save!
          history = create_history(:case_ref_obtained, submission.aasm_state, xml_request, response) if submission.obtain_applicant_ref!
          log_message("SubmissionHistory: #{history.id}: using existing applicant reference #{applicant_ccms_reference}")
        end
      end

      def legal_aid_application
        submission.legal_aid_application
      end

      def xml_request
        @xml_request ||= applicant_search_requestor.formatted_xml
      end
    end
  end
end
