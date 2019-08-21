module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    self.table_name = :ccms_submissions

    belongs_to :legal_aid_application

    validates :legal_aid_application_id, presence: true

    serialize :documents, Hash

    POLL_LIMIT = 10

    def process!(options = {}) # rubocop:disable Metrics/MethodLength
      case aasm_state
      when 'initialised'
        ObtainCaseReferenceService.call(self)
      when 'case_ref_obtained'
        ObtainApplicantReferenceService.call(self)
      when 'applicant_submitted'
        CheckApplicantStatusService.call(self)
      when 'case_created'
        UploadDocumentsService.call(self)
      when 'document_ids_obtained'
        AddCaseService.call(self, options)
      when 'applicant_ref_obtained'
        ObtainDocumentIdService.call(self)
      when 'case_submitted'
        CheckCaseStatusService.call(self)
      else
        raise CcmsError, "Unknown state: #{aasm_state}"
      end
    end

    def process_async!
      SubmissionProcessWorker.perform_async(id, aasm_state)
    end
  end
end
