module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    self.table_name = :ccms_submissions

    belongs_to :legal_aid_application

    validates :legal_aid_application_id, presence: true

    POLL_LIMIT = 10

    def process! # rubocop:disable Metrics/MethodLength
      case aasm_state
      when 'initialised'
        ObtainCaseReferenceService.call(self)
      when 'case_ref_obtained'
        ObtainApplicantReferenceService.call(self)
      when 'applicant_submitted'
        CheckApplicantStatusService.call(self)
      when 'applicant_ref_obtained'
        AddCaseService.call(self)
      when 'case_submitted'
        CheckCaseStatusService.call(self)
      else
        raise CcmsError, 'Unknown state'
      end
    end
  end
end
