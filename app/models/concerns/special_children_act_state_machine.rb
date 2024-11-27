class SpecialChildrenActStateMachine < NonMeansTestedStateMachine
  def case_add_requestor
    CCMS::Requestors::SpecialChildrenActCaseAddRequestor
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
end
