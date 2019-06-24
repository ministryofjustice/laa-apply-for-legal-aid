module CCMS
  class AddCaseService < BaseSubmissionService
    def call
      if case_add_response_parser.success?
        submission.case_add_transaction_id = case_add_requestor.transaction_request_id
        create_history('applicant_ref_obtained', submission.aasm_state) if submission.submit_case!
      else
        handle_failure(response)
      end
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def case_add_requestor
      @case_add_requestor ||= CaseAddRequestor.new(submission)
    end

    def case_add_response_parser
      @case_add_response_parser ||= CaseAddResponseParser.new(case_add_requestor.transaction_request_id, response)
    end

    def response
      @response ||= case_add_requestor.call
    end
  end
end
