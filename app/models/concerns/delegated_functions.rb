module DelegatedFunctions
  def used_delegated_functions?
    proceedings.any?(&:used_delegated_functions?)
  end

  def non_sca_used_delegated_functions?
    used_delegated_functions? && !special_children_act_proceedings?
  end

  def used_delegated_functions_on
    earliest_delegated_functions_date
  end

  def used_delegated_functions_reported_on
    proceedings.using_delegated_functions.first&.used_delegated_functions_reported_on
  end

  def proceeding_with_earliest_delegated_functions
    proceedings.using_delegated_functions.first
  end

  def earliest_delegated_functions_date
    proceeding_with_earliest_delegated_functions&.used_delegated_functions_on
  end

  def earliest_delegated_functions_reported_date
    # This returns the reported_at date of the APT with the earliest used_delegated_functions_on
    # which is not always the same as the earliest used_delegated_functions_reported_on
    proceeding_with_earliest_delegated_functions&.used_delegated_functions_reported_on
  end
end
