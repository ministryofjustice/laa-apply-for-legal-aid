class NonMeansTestedStateMachine < BaseStateMachine
  aasm do
    # TODO: required by #status_change_not_required? so should probably be promoted to superclass
    state :applicant_entering_means
    state :awaiting_applicant
    state :provider_assessing_means

    # TODO: the following event is required to allow jumping to provider entering merits
    event :provider_enter_merits do
      transitions from: :applicant_details_checked, to: :provider_entering_merits
    end

    event :check_applicant_details do
      transitions from: %i[entering_applicant_details
                           provider_entering_merits
                           applicant_details_checked],
                  to: :checking_applicant_details
    end
  end

  # TODO: required by #checking_answers? so should probably be promoted to superclass
  def checking_passported_answers?
    false
  end

  # TODO: required by #checking_answers? so should probably be promoted to superclass
  def checking_citizen_answers?
    false
  end

  # TODO: required by #checking_answers? so should probably be promoted to superclass
  def checking_non_passported_means?
    false
  end
end
