module CCMS
  class Submission < ApplicationRecord
    include AASM

    self.table_name = :ccms_submissions

    belongs_to :legal_aid_application

    validates :legal_aid_application_id, presence: true

    aasm do
      state :initialised, initial: true
      state :case_ref_obtained
      state :applicant_submitted
      state :applicant_ref_obtained
      state :case_submitted
      state :case_created
      state :failed

      event :obtain_case_ref do
        transitions from: :initialised, to: :case_ref_obtained
      end

      event :submit_applicant do
        transitions from: :case_ref_obtained, to: :applicant_submitted
      end

      event :obtain_applicant_ref do
        transitions from: :applicant_submitted, to: :applicant_ref_obtained
      end

      event :submit_case do
        transitions from: :applicant_ref_obtained, to: :case_submitted
      end

      event :confirm_case_created do
        transitions from: :case_submitted, to: :case_created
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :case_ref_obtained, to: :failed
        transitions from: :applicant_submitted, to: :failed
        transitions from: :applicant_ref_obtained, to: :failed
        transitions from: :case_submitted, to: :failed
      end
    end


    def process!
      case aasm_state
      when 'initialised'
        get_case_reference
      else
        raise 'Unknown state'
      end
    end

    private

    def get_case_reference
      begin
        tx_id = reference_data_requestor.transaction_request_id
        response = reference_data_requestor.call
        result = ReferenceDataParser.new(tx_id, response).parse
        self.case_ccms_reference = result
        self.obtain_case_ref!
      rescue => err
        self.fail!
      end
    end

    def reference_data_requestor
      @reference_data_requestor ||= ReferenceDataRequestor.new
    end
  end
end
