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

    POLL_LIMIT = Rails.env.development? ? 99 : 20

    BASE_DELAY = 5.seconds.freeze

    STATE_SERVICES = {
      initialised: CCMS::Submitters::ObtainCaseReferenceService,
      case_ref_obtained: CCMS::Submitters::ObtainApplicantReferenceService,
      applicant_submitted: CCMS::Submitters::CheckApplicantStatusService,
      applicant_ref_obtained: CCMS::Submitters::ObtainDocumentIdService,
      document_ids_obtained: CCMS::Submitters::AddCaseService,
      case_submitted: CCMS::Submitters::CheckCaseStatusService,
      case_created: CCMS::Submitters::UploadDocumentsService
    }.freeze

    def process!(options = {})
      service = STATE_SERVICES[aasm_state.to_sym]
      raise CCMSError, "Submission #{id} - Unknown state: #{aasm_state}" if service.nil?

      if aasm_state.eql?('document_ids_obtained')
        service.call(self, options)
      else
        service.call(self)
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
