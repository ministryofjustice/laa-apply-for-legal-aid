module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_documents, dependent: :destroy
    has_many :submission_history, dependent: :destroy

    # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
    validates :legal_aid_application_id, presence: true
    # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo

    after_save do
      ActiveSupport::Notifications.instrument "dashboard.ccms_submission_saved", id:, state: aasm_state
    end

    POLL_LIMIT = Rails.env.development? ? 99 : 20

    STATE_SERVICES = {
      initialised: CCMS::Submitters::ObtainCaseReferenceService,
      case_ref_obtained: CCMS::Submitters::ObtainApplicantReferenceService,
      applicant_submitted: CCMS::Submitters::CheckApplicantStatusService,
      applicant_ref_obtained: CCMS::Submitters::ObtainDocumentIdService,
      document_ids_obtained: CCMS::Submitters::AddCaseService,
      case_submitted: CCMS::Submitters::CheckCaseStatusService,
      case_created: CCMS::Submitters::UploadDocumentsService,
    }.freeze

    def process!(options = {})
      service = STATE_SERVICES[aasm_state.to_sym]
      raise CCMSError, "Submission #{id} - Unknown state: #{aasm_state}" if service.nil?

      if aasm_state.eql?("document_ids_obtained")
        service.call(self, options)
      else
        service.call(self)
      end
    end

    def process_async!
      SubmissionProcessWorker.perform_async(id, aasm_state)
    end
    alias_method :restart_current_step!, :process_async!

    def sidekiq_running?
      return :running if Sidekiq::Workers.new.map(&:to_s).to_s.scan(id).count.positive?
      return :in_retry if Sidekiq::RetrySet.new.any? { |job| job.args.include?(id) }

      false
    end

    def restart_from_beginning!
      update!(aasm_state: "initialised", case_poll_count: 0, applicant_poll_count: 0)
      process_async!
    end
  end
end
