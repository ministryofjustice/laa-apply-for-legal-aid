class PassportedStateMachine < BaseStateMachine # rubocop:disable Metrics/ClassLength
  aasm do # rubocop:disable Metrics/BlockLength
    state :provider_entering_means
    state :checking_passported_answers

    event :provider_enter_means do
      transitions from: %i[
        applicant_details_checked
        delegated_functions_used
        provider_entering_means
        use_ccms
      ],
                  to: :provider_entering_means,
                  after: proc { |_legal_aid_application|
                    update!(ccms_reason: nil) unless ccms_reason.nil?
                  }
    end

    event :check_passported_answers do
      transitions from: %i[
        provider_entering_means
        delegated_functions_used
        provider_entering_merits
      ],
                  to: :checking_passported_answers
    end

    event :complete_passported_means do
      transitions from: :checking_passported_answers, to: :provider_entering_merits
    end
  end

  def checking_non_passported_means?
    false
  end

  def checking_citizen_answers?
    false
  end

  def applicant_entering_means?
    false
  end

  # :nocov:
  def provider_assessing_means?
    false
  end
  # :nocov:

  def awaiting_applicant?
    false
  end

  def provider_checking_or_checked_citizens_means_answers?
    false
  end
end
