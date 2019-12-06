module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_document, dependent: :destroy
    has_many :submission_history, dependent: :destroy

    validates :legal_aid_application_id, presence: true

    after_save do
      ActiveSupport::Notifications.instrument "dashboard.ccms_submission_saved", { id: id, state: aasm_state }
    end

    POLL_LIMIT = 10

    def process!(options = {}) # rubocop:disable Metrics/MethodLength
      case aasm_state
      when 'initialised'
        ObtainCaseReferenceService.call(self)
      when 'case_ref_obtained'
        ObtainApplicantReferenceService.call(self)
      when 'applicant_submitted'
        CheckApplicantStatusService.call(self)
      when 'applicant_ref_obtained'
        ObtainDocumentIdService.call(self)
      when 'document_ids_obtained'
        AddCaseService.call(self, options)
      when 'case_submitted'
        CheckCaseStatusService.call(self)
      when 'case_created'
        UploadDocumentsService.call(self)
      else
        raise CcmsError, "Submission #{id} - Unknown state: #{aasm_state}"
      end
    end

    def process_async!
      SubmissionProcessWorker.perform_async(id, aasm_state)
    end
  end
end
