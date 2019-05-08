module CCMS
  class AddApplicantService < BaseSubmissionService
    def call
      response = applicant_add_requestor.call
      if applicant_add_response_parser(response).success?
        create_history(submission.aasm_state, :applicant_submitted)
        submission.submit_applicant!
      else
        handle_failure(response)
      end
    rescue StandardError => e
      handle_failure(e)
    end

    private

    def applicant_add_requestor
      @applicant_add_requestor ||= ApplicantAddRequestor.new(submission.legal_aid_application.applicant)
    end

    def applicant_add_response_parser(response)
      @applicant_add_response_parser ||= ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
    end
  end
end
