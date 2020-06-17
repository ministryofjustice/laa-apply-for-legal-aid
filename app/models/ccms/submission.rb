module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_documents, dependent: :destroy
    has_many :submission_history, dependent: :destroy

    validates :legal_aid_application_id, presence: true

    after_save do
      ActiveSupport::Notifications.instrument 'dashboard.ccms_submission_saved', id: id, state: aasm_state
    end

    POLL_LIMIT = Rails.env.development? ? 99 : 10

    BASE_DELAY = 5.seconds.freeze

    def process!(options = {}) # rubocop:disable Metrics/MethodLength
      case aasm_state
      when 'initialised'
        CCMS::Submitters::ObtainCaseReferenceService.call(self)
      when 'case_ref_obtained'
        CCMS::Submitters::ObtainApplicantReferenceService.call(self)
      when 'applicant_submitted'
        CCMS::Submitters::CheckApplicantStatusService.call(self)
      when 'applicant_ref_obtained'
        CCMS::Submitters::ObtainDocumentIdService.call(self)
      when 'document_ids_obtained'
        CCMS::Submitters::AddCaseService.call(self, options)
      when 'case_submitted'
        CCMS::Submitters::CheckCaseStatusService.call(self)
      when 'case_created'
        CCMS::Submitters::UploadDocumentsService.call(self)
      else
        raise CcmsError, "Submission #{id} - Unknown state: #{aasm_state}"
      end
    end

    def process_async!
      SubmissionProcessWorker.perform_async(id, aasm_state)
    end

    def delay
      BASE_DELAY * (current_poll_count + 1)
    end

    private

    def current_poll_count
      case aasm_state
      when 'applicant_submitted'
        applicant_poll_count
      when 'case_submitted'
        case_poll_count
      else
        0
      end
    end
  end
end
