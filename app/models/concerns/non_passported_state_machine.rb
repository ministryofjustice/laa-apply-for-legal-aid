class NonPassportedStateMachine < BaseStateMachine # rubocop:disable Metrics/ClassLength
  aasm do # rubocop:disable Metrics/BlockLength
    state :provider_confirming_applicant_eligibility
    state :awaiting_applicant
    state :applicant_entering_means
    state :checking_citizen_answers
    state :analysing_bank_transactions
    state :provider_assessing_means
    state :checking_non_passported_means

    event :provider_confirm_applicant_eligibility do
      transitions from: %i[
        applicant_details_checked
        delegated_functions_used
        provider_confirming_applicant_eligibility
      ],
                  to: :provider_confirming_applicant_eligibility
    end

    event :await_applicant do
      transitions from: :provider_confirming_applicant_eligibility, to: :awaiting_applicant
      transitions from: :delegated_functions_used, to: :awaiting_applicant
    end

    event :applicant_enter_means do
      transitions from: %i[
        awaiting_applicant
        applicant_entering_means
        use_ccms
      ],
                  to: :applicant_entering_means,
                  after: proc { |_legal_aid_application|
                    update!(ccms_reason: nil) unless ccms_reason.nil?
                  }
    end

    event :check_citizen_answers do
      transitions from: :applicant_entering_means, to: :checking_citizen_answers
    end

    event :complete_non_passported_means do
      transitions from: :checking_citizen_answers, to: :analysing_bank_transactions,
                  after: proc { |legal_aid_application|
                    ApplicantCompleteMeans.call(legal_aid_application)
                    BankTransactionsAnalyserJob.perform_later(legal_aid_application)
                  }
    end

    event :complete_bank_transaction_analysis do
      transitions from: :analysing_bank_transactions, to: :provider_assessing_means
    end

    event :check_non_passported_means do
      transitions from: %i[
        provider_assessing_means
        provider_entering_merits
      ],
                  to: :checking_non_passported_means
    end

    event :reset_to_applicant_entering_means do
      transitions from: :use_ccms, to: :applicant_entering_means,
                  after: proc { update!(ccms_reason: nil) }
    end
  end

  def checking_passported_answers?
    false
  end

  def provider_checking_or_checked_citizens_means_answers?
    checking_non_passported_means? || provider_entering_merits?
  end
end
