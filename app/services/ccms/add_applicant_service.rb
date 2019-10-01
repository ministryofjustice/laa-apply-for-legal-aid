module CCMS
  class AddApplicantService < BaseSubmissionService
    def call
      if applicant_add_response_parser.success?
        submission.applicant_add_transaction_id = applicant_add_requestor.transaction_request_id
        create_history('case_ref_obtained', submission.aasm_state, xml_request) if submission.submit_applicant!
      else
        handle_failure(response, xml_request)
      end
    rescue CcmsError => e
      handle_ccms_failure(e, xml_request)
    end

    private

    def applicant_add_requestor
      @applicant_add_requestor ||= ApplicantAddRequestor.new(submission.legal_aid_application.applicant)
    end

    def applicant_add_response_parser
      @applicant_add_response_parser ||= ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
    end

    def response
      @response ||= applicant_add_requestor.call
    end

    def xml_request
      @xml_request ||= applicant_add_requestor.formatted_xml
    end

    # def xml_response
    #   @xml_response ||= applicant_add_response_parser.response
    # end
  end
end
