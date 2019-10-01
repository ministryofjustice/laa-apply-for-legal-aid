module CCMS
  class ObtainCaseReferenceService < BaseSubmissionService
    def call
      submission.case_ccms_reference = reference_id
      create_history(:initialised, submission.aasm_state, xml_request, xml_request) if submission.obtain_case_ref!
    rescue CcmsError => e
      handle_ccms_failure(e, xml_request)
    end

    def reference_id
      ReferenceDataResponseParser.new(transaction_request_id, response).reference_id
    end

    def response
      reference_data_requestor.call
    end

    def transaction_request_id
      reference_data_requestor.transaction_request_id
    end

    private

    def reference_data_requestor
      @reference_data_requestor ||= ReferenceDataRequestor.new
    end

    def reference_data_response_parser
      @reference_data_response_parser ||= ReferenceDataResponseParser.new(reference_data_requestor.transaction_request_id, response)
    end

    def xml_request
      @xml_request ||= reference_data_requestor.formatted_xml
    end

    def xml_response
      @xml_response ||= reference_data_requestor.formatted_xml
    end
  end
end
