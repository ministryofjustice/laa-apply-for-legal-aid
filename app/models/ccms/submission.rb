module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    self.table_name = :ccms_submissions

    belongs_to :legal_aid_application

    validates :legal_aid_application_id, presence: true

    POLL_LIMIT = 10.freeze

    def process!
      case aasm_state
      when 'initialised'
        ObtainCaseReferenceService.new(self).call
      when 'case_ref_obtained'
        ObtainApplicantReferenceService.new(self).call
      when 'applicant_submitted'
        CheckApplicantStatusService.new(self).call
      else
        raise CcmsError, 'Unknown state'
      end
    end
  end
end
