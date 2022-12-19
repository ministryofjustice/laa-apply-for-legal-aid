class NonMeansTestedStateMachine < BaseStateMachine
  def case_add_requestor
    CCMS::Requestors::NonMeansTestedCaseAddRequestor
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
