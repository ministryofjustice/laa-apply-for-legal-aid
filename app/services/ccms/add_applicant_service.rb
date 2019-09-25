module CCMS
  class AddApplicantService < BaseSubmissionService
    def call
      if applicant_add_response_parser.success?
        submission.applicant_add_transaction_id = applicant_add_requestor.transaction_request_id
        create_history('case_ref_obtained', submission.aasm_state, applicant_add_requestor, applicant_add_response_parser) if submission.submit_applicant!
      else
        handle_failure(response)
      end
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def applicant_add_requestor
      @applicant_add_requestor ||= ApplicantAddRequestor.new(submission.legal_aid_application.applicant)
    end

    def applicant_add_response_parser
      @applicant_add_response_parser ||= ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
    end

    def save_applicant_request
      # @applicant_add_requestor ||= ApplicantAddRequestor.new(submission.legal_aid_application.applicant)
      # @save_applicant_request ||=
    end

    def response
      @response ||= applicant_add_requestor.call
    end
  end
end
