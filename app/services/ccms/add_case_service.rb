module CCMS
  class AddCaseService < BaseSubmissionService
    def self.call(submission, options)
      new(submission).call(options)
    end

    def call(options = {})
      @options = options
      if case_add_response_parser.success?
        submission.case_add_transaction_id = case_add_requestor.transaction_request_id
        create_history(submission.submission_document.empty? ? 'applicant_ref_obtained' : 'document_ids_obtained', submission.aasm_state, xml_request, xml_response) if submission.submit_case!
      else
        handle_failure(response, xml_request, xml_response)
      end
    rescue CcmsError => e
      handle_ccms_failure(e, xml_request)
    end

    private

    def case_add_requestor
      @case_add_requestor ||= CaseAddRequestor.new(submission, @options)
    end

    def case_add_response_parser
      @case_add_response_parser ||= CaseAddResponseParser.new(case_add_requestor.transaction_request_id, response)
    end

    def response
      @response ||= case_add_requestor.call
    end

    def xml_request
      @xml_request ||= case_add_requestor.formatted_xml
    end

    def xml_response
      @xml_response ||= case_add_response_parser.doc
    end
  end
end
