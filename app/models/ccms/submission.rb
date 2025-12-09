module CCMS
  class Submission < ApplicationRecord
    include CCMSSubmissionStateMachine

    belongs_to :legal_aid_application
    has_many :submission_documents, dependent: :destroy
    has_many :submission_history, dependent: :destroy

    # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
    validates :legal_aid_application_id, presence: true
    # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo

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

    def case_add_requestor(options = {})
      legal_aid_application.case_add_requestor.new(self, options)
    end

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

    def sidekiq_status
      return :running if Sidekiq::Workers.new.map(&:to_s).to_s.scan(id).any?
      return :in_retry if Sidekiq::RetrySet.new.any? { |job| job.args.include?(id) }
      return :scheduled if Sidekiq::ScheduledSet.new.any? { |job| job.args.include?(id) }
      return :dead if Sidekiq::DeadSet.new.any? { |job| job.args.include?(id) }

      :undetermined
    end

    def sidekiq_running?
      %i[running in_retry].include? sidekiq_status
    end

    def restart_from_beginning!
      update!(aasm_state: "initialised", case_poll_count: 0, applicant_poll_count: 0)
      process_async!
    end
  end
end
