module CCMS
  class ObtainCaseReferenceService < BaseSubmissionService
    def call
      tx_id = reference_data_requestor.transaction_request_id
      response = reference_data_requestor.call
      submission.case_ccms_reference = ReferenceDataResponseParser.new(tx_id, response).parse
      create_history(submission.aasm_state, :case_ref_obtained)
      submission.obtain_case_ref!
    rescue StandardError => e
      handle_failure(e)
    end

    private

    def reference_data_requestor
      @reference_data_requestor ||= ReferenceDataRequestor.new
    end
  end
end
