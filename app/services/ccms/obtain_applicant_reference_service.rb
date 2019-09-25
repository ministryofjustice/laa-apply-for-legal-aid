module CCMS
  class ObtainApplicantReferenceService < BaseSubmissionService
    def call
      tx_id = applicant_search_requestor.transaction_request_id
      response = applicant_search_requestor.call
      parser = ApplicantSearchResponseParser.new(tx_id, response)
      process_records(parser)
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def applicant_search_requestor
      @applicant_search_requestor ||= ApplicantSearchRequestor.new(submission.legal_aid_application.applicant)
    end

    def process_records(parser)
      if parser.record_count.to_i.zero?
        AddApplicantService.new(submission).call
      else
        submission.applicant_ccms_reference = parser.applicant_ccms_reference
        create_history(:case_ref_obtained, submission.aasm_state, applicant_search_requestor) if submission.obtain_applicant_ref!
      end
    end
  end
end
