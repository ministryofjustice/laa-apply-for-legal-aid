class BaseStateMachine < ApplicationRecord
  self.table_name = "state_machine_proxies"

  belongs_to :legal_aid_application
  delegate :non_means_tested?, to: :legal_aid_application

  def allow_ccms_submission?
    EnableCCMSSubmission.call || ENV.fetch("LOCAL_CCMS_OVERRIDE", "false") == "true"
  end

  def log_status_change
    Rails.logger.info "BaseStateMachine::StateChange, laa_id: #{legal_aid_application.id}, event: #{aasm.current_event}, from: #{aasm.from_state}, to: #{aasm.to_state}"
  end

  VALID_CCMS_REASONS = %i[
    no_online_banking
    no_applicant_consent
    non_passported
    offline_accounts
    unknown
    applicant_self_employed
    applicant_armed_forces
    partner_self_employed
    partner_armed_forces
  ].freeze

  PRE_DWP_STATES = %i[
    initiated
    entering_applicant_details
    checking_applicant_details
  ].freeze

  include AASM

  aasm do
    state :initiated, initial: true
    state :entering_applicant_details
    state :checking_applicant_details
    state :applicant_details_checked
    state :overriding_dwp_result
    state :provider_entering_merits
    state :checking_merits_answers
    state :generating_reports
    state :submission_paused
    state :submitting_assessment
    state :assessment_submitted
    state :use_ccms
    state :delegated_functions_used

    after_all_transitions :log_status_change

    event :enter_applicant_details do
      transitions from: %i[
                    initiated
                    applicant_details_checked
                    provider_entering_means
                    checking_applicant_details
                    use_ccms
                  ],
                  to: :entering_applicant_details
    end

    event :check_applicant_details do
      transitions from: %i[
                    entering_applicant_details
                    applicant_details_checked
                    provider_confirming_applicant_eligibility
                    overriding_dwp_result
                    use_ccms
                  ],
                  to: :checking_applicant_details

      transitions from: :provider_entering_merits, to: :checking_applicant_details, guard: :non_means_tested?
    end

    event :applicant_details_checked do
      transitions from: %i[
                    provider_entering_means
                    checking_applicant_details
                    provider_confirming_applicant_eligibility
                    use_ccms
                    delegated_functions_used
                    overriding_dwp_result
                  ],
                  to: :applicant_details_checked

      transitions from: :provider_entering_merits, to: :applicant_details_checked, guard: proc { non_means_tested? }
    end

    event :override_dwp_result do
      transitions from: %i[
                    checking_applicant_details
                    applicant_details_checked
                  ],
                  to: :overriding_dwp_result
    end

    event :provider_used_delegated_functions do
      transitions from: %i[
                    provider_entering_means
                    applicant_details_checked
                    delegated_functions_used
                    checking_applicant_details
                    provider_confirming_applicant_eligibility
                  ],
                  to: :delegated_functions_used
    end

    event :use_ccms do
      transitions from: %i[
                    initiated
                    entering_applicant_details
                    checking_applicant_details
                    applicant_details_checked
                    delegated_functions_used
                    provider_confirming_applicant_eligibility
                    applicant_entering_means
                    provider_assessing_means
                    assessing_partner_means
                    use_ccms
                  ],
                  to: :use_ccms,
                  after: proc { |reason|
                    raise "Invalid ccms_reason" unless reason.in?(VALID_CCMS_REASONS)

                    update!(ccms_reason: reason)
                  }
    end

    event :reset do
      transitions from: :checking_applicant_details, to: :entering_applicant_details
      transitions from: :checking_citizen_answers, to: :applicant_entering_means
      transitions from: :checking_passported_answers, to: :provider_entering_means
      transitions from: :checking_merits_answers, to: :provider_entering_merits
      transitions from: :provider_entering_merits, to: :provider_entering_merits
    end

    event :provider_enter_merits do
      transitions from: :checking_non_passported_means, to: :provider_entering_merits
      transitions from: %i[
                    merits_parental_responsibilities_all_rejected
                    merits_parental_responsibilities
                    applicant_details_checked
                  ],
                  to: :provider_entering_merits,
                  guard: :non_means_tested?
    end

    event :check_merits_answers do
      transitions from: %i[
                    provider_entering_merits
                    checked_merits_answers
                    submitting_assessment
                    assessment_submitted
                  ],
                  to: :checking_merits_answers
      transitions from: :applicant_details_checked, to: :checking_merits_answers, guard: :non_means_tested?
      transitions from: %i[
                    merits_parental_responsibilities_all_rejected
                    merits_parental_responsibilities
                  ],
                  to: :checking_merits_answers,
                  guard: :non_means_tested?
    end

    event :generate_reports do
      transitions from: :checking_merits_answers, to: :generating_reports,
                  after: proc { |legal_aid_application|
                    ReportsCreatorWorker.perform_async(legal_aid_application.id)
                    PostSubmissionProcessingJob.perform_later(legal_aid_application.id, "#{Rails.configuration.x.application.host_url}/feedback/new")
                  },
                  guards: [:allow_ccms_submission?]
      transitions from: :checking_merits_answers, to: :submission_paused
    end

    event :generated_reports do
      transitions from: :generating_reports, to: :submitting_assessment,
                  after: proc { |legal_aid_application|
                           legal_aid_application.find_or_create_ccms_submission.process_async! if Rails.configuration.x.ccms_soa.submit_applications_to_ccms
                         }
    end

    event :restart_submission do
      transitions from: :submission_paused, to: :generating_reports,
                  after: proc { |legal_aid_application|
                    ReportsCreatorWorker.perform_async(legal_aid_application.id)
                    PostSubmissionProcessingJob.perform_later(legal_aid_application.id, "#{Rails.configuration.x.application.host_url}/feedback/new")
                  },
                  guards: [:allow_ccms_submission?]
    end

    event :submitted_assessment do
      transitions from: %i[submission_paused submitting_assessment], to: :assessment_submitted
    end

    event :reset_from_use_ccms do
      transitions from: :use_ccms, to: :applicant_details_checked,
                  after: proc { update!(ccms_reason: nil) }
    end
  end
end
