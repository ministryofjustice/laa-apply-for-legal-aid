class NonPassportedStateMachine < BaseStateMachine
  def case_add_requestor
    CCMS::Requestors::NonPassportedCaseAddRequestor
  end

  aasm do
    state :provider_confirming_applicant_eligibility
    state :awaiting_applicant
    state :applicant_entering_means
    state :checking_citizen_answers
    state :analysing_bank_transactions
    state :provider_assessing_means
    state :assessing_partner_means
    state :checking_means_income
    state :checking_non_passported_means

    event :provider_confirm_applicant_eligibility do
      transitions from: %i[
                    applicant_details_checked
                    delegated_functions_used
                    provider_confirming_applicant_eligibility
                    provider_assessing_means
                    checking_applicant_details
                  ],
                  to: :provider_confirming_applicant_eligibility
      transitions from: :stateless, to: :stateless
    end

    event :await_applicant do
      transitions from: :provider_confirming_applicant_eligibility, to: :awaiting_applicant
      transitions from: :delegated_functions_used, to: :awaiting_applicant
      transitions from: :awaiting_applicant, to: :awaiting_applicant
      transitions from: :stateless, to: :stateless
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
      transitions from: :stateless, to: :stateless
    end

    event :check_citizen_answers do
      transitions from: :applicant_entering_means, to: :checking_citizen_answers
      transitions from: :stateless, to: :stateless
    end

    event :complete_non_passported_means do
      transitions from: :checking_citizen_answers, to: :analysing_bank_transactions,
                  after: proc { |legal_aid_application|
                    ApplicantCompleteMeans.call(legal_aid_application)
                    BankTransactionsAnalyserJob.perform_later(legal_aid_application)
                  }
      transitions from: :stateless, to: :stateless
    end

    event :complete_bank_transaction_analysis do
      transitions from: :analysing_bank_transactions, to: :provider_assessing_means
      transitions from: :stateless, to: :stateless
    end

    event :provider_assess_means do
      transitions from: %i[provider_confirming_applicant_eligibility
                           provider_assessing_means
                           checking_means_income
                           checking_non_passported_means],
                  to: :provider_assessing_means
      transitions from: :stateless, to: :stateless
    end

    event :assess_partner_means do
      transitions from: %i[
                    provider_confirming_applicant_eligibility
                    provider_assessing_means
                    assessing_partner_means
                    use_ccms
                  ],
                  to: :assessing_partner_means
      transitions from: :stateless, to: :stateless
    end

    event :check_non_passported_means do
      transitions from: %i[
                    provider_assessing_means
                    provider_entering_merits
                    checking_means_income
                  ],
                  to: :checking_non_passported_means
      transitions from: :stateless, to: :stateless
    end

    event :reset_to_applicant_entering_means do
      transitions from: :use_ccms, to: :applicant_entering_means,
                  after: proc { update!(ccms_reason: nil) }
    end

    event :check_means_income do
      transitions from: %i[
                    provider_assessing_means
                    assessing_partner_means
                  ],
                  to: :checking_means_income
      transitions from: :stateless, to: :stateless
    end
  end

  def checking_passported_answers?
    false
  end

  def provider_checking_or_checked_citizens_means_answers?
    checking_non_passported_means? || provider_entering_merits?
  end
end
