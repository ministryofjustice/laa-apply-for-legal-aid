module CCMS
  class Submission < ApplicationRecord
    include AASM

    self.table_name = :ccms_submissions

    aasm do
      state :initialised, initial: true
      state :case_ref_obtained
      state :applicant_submitted
      state :applicant_ref_obtained
      state :case_submitted
      state :submission_confirmed
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

      event :confirm_submission do
        transitions from: :case_submitted, to: :submission_confirmed
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :case_ref_obtained, to: :failed
        transitions from: :applicant_submitted, to: :failed
        transitions from: :applicant_ref_obtained, to: :failed
        transitions from: :case_submitted, to: :failed
        transitions from: :submission_confirmed, to: :failed
      end

    end


  end
end
