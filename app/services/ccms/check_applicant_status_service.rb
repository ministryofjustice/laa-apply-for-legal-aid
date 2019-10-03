module CCMS
  class CheckApplicantStatusService < BaseSubmissionService
    def call
      tx_id = applicant_add_status_requestor.transaction_request_id
      submission.applicant_poll_count += 1
      submission.save
      response = applicant_add_status_requestor.call
      parser = ApplicantAddStatusResponseParser.new(tx_id, response)
      process_response(parser)
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def process_response(parser)
      if parser.success?
        submission.applicant_ccms_reference = parser.applicant_ccms_reference
        create_history(:applicant_submitted, submission.aasm_state) if submission.obtain_applicant_ref!
      elsif submission.applicant_poll_count >= Submission::POLL_LIMIT
        handle_failure('Poll limit exceeded')
      else
        create_history(submission.aasm_state, submission.aasm_state)
      end
    end

    def applicant_add_status_requestor
      @applicant_add_status_requestor ||= ApplicantAddStatusRequestor.new(submission.applicant_add_transaction_id)
    end
  end
end
