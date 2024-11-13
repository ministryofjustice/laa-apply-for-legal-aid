class NonMeansTestedStateMachine < BaseStateMachine
  def case_add_requestor
    CCMS::Requestors::NonMeansTestedCaseAddRequestor
  end

  aasm do
    state :merits_parental_responsibilities
    state :merits_parental_responsibilities_all_rejected

    event :provider_recording_parental_responsibilities do
      transitions from: :provider_entering_merits, to: :merits_parental_responsibilities
      transitions from: :merits_parental_responsibilities, to: :merits_parental_responsibilities
      transitions from: :merits_parental_responsibilities_all_rejected, to: :merits_parental_responsibilities_all_rejected
      transitions from: :checking_merits_answers, to: :merits_parental_responsibilities
    end

    event :rejected_all_parental_responsibilities do
      transitions from: :provider_entering_merits, to: :merits_parental_responsibilities_all_rejected
      transitions from: :merits_parental_responsibilities, to: :merits_parental_responsibilities_all_rejected
      transitions from: :merits_parental_responsibilities_all_rejected, to: :merits_parental_responsibilities_all_rejected
    end
  end
  # The following methods override events that are not applicable for a
  # non-means-tested journey but which, nonetheless, must be responded to when calls
  # are made to legal_aid_application#checking_answers? or refered to by other "helper"
  # methods :(

  def applicant_entering_means?
    false
  end

  def awaiting_applicant?
    false
  end

  def provider_assessing_means?
    false
  end

  def checking_passported_answers?
    false
  end

  def checking_citizen_answers?
    false
  end

  def checking_non_passported_means?
    false
  end

  def checking_means_income?
    false
  end
end
