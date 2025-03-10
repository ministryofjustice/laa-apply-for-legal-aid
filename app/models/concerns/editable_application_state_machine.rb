class EditableApplicationStateMachine < BaseStateMachine
  def case_add_requestor
    raise "TODO: implement for editable applications"
  end

  aasm do
    state :checking_task_list, initial: true
    event :check_task_list do
      transitions to: :checking_task_list
    end

    state :checking_applicant_details
    event :check_applicant_details do
      transitions to: :checking_applicant_details
    end

    state :checking_passported_answers
    event :check_passported_answers do
      transitions to: :checking_passported_answers
    end

    state :checking_citizen_answers
    event :check_citizen_answers? do
      transitions to: :checking_citizen_answers
    end

    state :checking_non_passported_means
    event :check_non_passported_means do
      transitions to: :checking_non_passported_means
    end

    state :checking_means_income
    event :check_means_income do
      transitions to: :checking_means_income
    end
  end

  # The following methods override state queries and events that are not applicable for an
  # editable application journey but which, nonetheless, must be responded to when calls
  # are made in controllers :(

  #######################################################################
  #     Added to ignore these events for editable applications list     #
  #######################################################################
  def entering_applicant_details?
    false
  end

  def enter_applicant_details!
    false
  end

  def applicant_details_checked?
    false
  end

  def applicant_details_checked!(_self)
    false
  end

  def use_ccms!(_use_ccms_reason)
    false
  end

  def provider_confirm_applicant_eligibility!
    false
  end

  def provider_entering_means?
    false
  end

  def provider_enter_means!
    false
  end

  def provider_assessing_means?
    false
  end

  def provider_assess_means!
    false
  end

  def applicant_entering_means?
    false
  end

  def applicant_enter_means!
    false
  end

  # will probably need handling
  def awaiting_applicant?
    false
  end

  # will probably need handling
  def await_applicant!
    false
  end

  def overriding_dwp_result?
    false
  end

  def override_dwp_result!(_self)
    false
  end
end
