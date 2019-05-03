module CCMS
  class Submission < ApplicationRecord # rubocop:disable Metrics/ClassLength
    include CCMSSubmissionStateMachine

    self.table_name = :ccms_submissions

    belongs_to :legal_aid_application

    validates :legal_aid_application_id, presence: true

    def process!
      case aasm_state
      when 'initialised'
        obtain_case_reference
      when 'case_ref_obtained'
        obtain_applicant_reference
      else
        raise 'Unknown state'
      end
    end

    private

    def obtain_case_reference
      tx_id = reference_data_requestor.transaction_request_id
      response = reference_data_requestor.call
      self.case_ccms_reference = ReferenceDataResponseParser.new(tx_id, response).parse
      create_history(aasm_state, :case_ref_obtained)
      obtain_case_ref!
    rescue StandardError => e
      create_failure_history(aasm_state, e)
      fail!
    end

    def obtain_applicant_reference # rubocop:disable Metrics/MethodLength
      tx_id = applicant_search_requestor.transaction_request_id
      response = applicant_search_requestor.call
      parser = ApplicantSearchResponseParser.new(tx_id, response)
      parser.parse
      if parser.record_count == '0'
        add_applicant
      else
        self.applicant_ccms_reference = parser.applicant_ccms_reference
        create_history(aasm_state, :applicant_ref_obtained)
        obtain_applicant_ref!
      end
    rescue StandardError => e
      create_failure_history(aasm_state, e)
      fail!
    end

    def add_applicant
      response = applicant_add_requestor.call
      if applicant_add_response_parser(response).parse == 'Success'
        create_history(aasm_state, :applicant_submitted)
        submit_applicant!
      else
        create_failure_history(aasm_state, response)
        fail!
      end
    rescue StandardError => e
      create_failure_history(aasm_state, e)
      fail!
    end

    def reference_data_requestor
      @reference_data_requestor ||= ReferenceDataRequestor.new
    end

    def applicant_search_requestor
      @applicant_search_requestor ||= ApplicantSearchRequestor.new(legal_aid_application.applicant)
    end

    def applicant_add_requestor
      @applicant_add_requestor ||= ApplicantAddRequestor.new(legal_aid_application.applicant)
    end

    def applicant_add_response_parser(response)
      @applicant_add_response_parser ||= ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
    end

    def create_history(from_state, to_state)
      SubmissionHistory.create submission: self,
                               from_state: from_state,
                               to_state: to_state,
                               success: true
    end

    def create_failure_history(from_state, error)
      SubmissionHistory.create submission: self,
                               from_state: from_state,
                               to_state: :failed,
                               success: false,
                               details: error.is_a?(Exception) ? format_exception(error) : error
    end

    def format_exception(error)
      [error.class, error.message, error.backtrace].flatten.join("\n")
    end
  end
end
