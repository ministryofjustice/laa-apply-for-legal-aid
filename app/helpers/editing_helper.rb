module EditingHelper
  # TODO: can we use legal aid application data to construct the array and perhaps use a state machine
  # to determine which section we are in and therefore whether it should be shownn. Or something like
  # sidebar displayable state set in the controller?! wrap up in a service class!
  #

  def editing_sidebar_items_for(end_of_path)
    {
      # DWP override
      "dwp-override" => financial_assessment_sidebar_items,
      "check_client_details" => financial_assessment_sidebar_items,
      "advise-of-passport-benefit" => financial_assessment_sidebar_items,
      "received_benefit_confirmation" => financial_assessment_sidebar_items,
      "has_evidence_of_benefit" => financial_assessment_sidebar_items,

      # financial assessment
      "about_financial_means" => financial_assessment_sidebar_items,
      "applicant_employed" => financial_assessment_sidebar_items,
      "employed" => financial_assessment_sidebar_items, # partner/employed
      "substantive_application" => financial_assessment_sidebar_items,
      "does-client-use-online-banking" => financial_assessment_sidebar_items,

      # upload bank statements flow
      "bank_statements" => financial_assessment_sidebar_items,
      "full_employment_details" => financial_assessment_sidebar_items,
      "receives_state_benefits" => financial_assessment_sidebar_items,
      "state_benefits" => financial_assessment_sidebar_items, # explicitly called
      "add_other_state_benefits" => financial_assessment_sidebar_items,
      "remove_state_benefits" => financial_assessment_sidebar_items, # explicitly called
      "regular_incomes" => financial_assessment_sidebar_items,
      "cash_income" => financial_assessment_sidebar_items,
      "student_finance" => financial_assessment_sidebar_items,
      "regular_outgoings" => financial_assessment_sidebar_items,
      "cash_outgoing" => financial_assessment_sidebar_items,
      "housing_benefits" => financial_assessment_sidebar_items,
      "has_dependants" => financial_assessment_sidebar_items,
      "dependants" => financial_assessment_sidebar_items, # explicitly called
      "has_other_dependants" => financial_assessment_sidebar_items,
      "remove_dependants" => financial_assessment_sidebar_items, # explicitly called

      # TODO: open banking flow
      "open_banking_guidance" => financial_assessment_sidebar_items,
      "email_address" => financial_assessment_sidebar_items,
      "about_the_financial_assessment" => financial_assessment_sidebar_items, # email address confirmation page
      "client_completed_means" => financial_assessment_sidebar_items,
      "identify_types_of_income" => financial_assessment_sidebar_items,
      "income_summary" => financial_assessment_sidebar_items,
      "identify_types_of_outgoing" => financial_assessment_sidebar_items,
      "outgoings_summary" => financial_assessment_sidebar_items,

      # capital and assets
      "capital_introduction" => capital_and_assets_sidebar_items,
      "own_home" => capital_and_assets_sidebar_items,
      "property_details" => capital_and_assets_sidebar_items,
      "vehicle" => capital_and_assets_sidebar_items,
      "vehicle_details" => capital_and_assets_sidebar_items,
      "remove_vehicles" => capital_and_assets_sidebar_items,
      "add_other_vehicles" => capital_and_assets_sidebar_items,
      "offline_account" => capital_and_assets_sidebar_items,
      "savings_and_investment" => capital_and_assets_sidebar_items,
      "other_assets" => capital_and_assets_sidebar_items,
      "restrictions" => capital_and_assets_sidebar_items,
      "disregarded_payments" => capital_and_assets_sidebar_items,
      "capital_disregards/add_details" => capital_and_assets_sidebar_items,
      "payments_to_review" => capital_and_assets_sidebar_items,

      # merits task list
      "merits_task_list" => merits_sidebar_items,

      # application merits tasks
      "involved_children" => merits_sidebar_items,
      "has_other_involved_children" => merits_sidebar_items,
      "opponent_individuals" => merits_sidebar_items,
      "opponent_new_organisations" => merits_sidebar_items,
      "opponent_existing_organisations" => merits_sidebar_items,
      "client_denial_of_allegation" => merits_sidebar_items,
      "client_offered_undertakings" => merits_sidebar_items,
      "date_client_told_incident" => merits_sidebar_items,
      "in_scope_of_laspo" => merits_sidebar_items,
      "has_other_opponent" => merits_sidebar_items,
      "opponent_type" => merits_sidebar_items,
      "opponents_mental_capacity" => merits_sidebar_items,
      "domestic_abuse_summary" => merits_sidebar_items,
      "matter_opposed_reason" => merits_sidebar_items,
      "nature_of_urgencies" => merits_sidebar_items,
      "client_is_biological_parent" => merits_sidebar_items,
      "client_has_parental_responsibility" => merits_sidebar_items,
      "client_is_child_subject" => merits_sidebar_items,
      "client_check_parental_answer" => merits_sidebar_items,
      "statement_of_case" => merits_sidebar_items,
      "statement_of_case_upload" => merits_sidebar_items,
      "second_appeal" => merits_sidebar_items,
      "original_case_judge_level" => merits_sidebar_items,
      "appeal_court_type" => merits_sidebar_items,
      "second_appeal_court_type" => merits_sidebar_items,
      "court_order" => merits_sidebar_items,
      "is_matter_opposed" => merits_sidebar_items,
      "when_contact_was_made" => merits_sidebar_items,

      # proceedings merits tasks
      "chances_of_success" => merits_sidebar_items,
      "attempts_to_settle" => merits_sidebar_items,
      "linked_children" => merits_sidebar_items,
      "opponents_application" => merits_sidebar_items,
      "prohibited_steps" => merits_sidebar_items,
      "specific_issue" => merits_sidebar_items,
      "changes_since_original" => merits_sidebar_items,
      "assessment_of_client" => merits_sidebar_items,
      "assessment_result" => merits_sidebar_items,

      # other merits pages
      "uploaded_evidence_collection" => merits_sidebar_items,

      # post merits pages
      "confirm_client_declaration" => all_sidebar_items,
    }.fetch(end_of_path, [])
  end

  def financial_assessment_sidebar_items
    %i[client_details]
  end

  # TODO: this relies on ApplicationDependable making the legal_aid_application method a helper_method,
  # which is not a good solution from a maintenance point of view.
  # This requires a handler for NameError if the controller does not have ApplicationDependable included,
  # and ActiveRecord::RecordNotFound if the pages, such as select_office, has no application id.
  #
  def capital_and_assets_sidebar_items
    if legal_aid_application.non_passported?
      %i[client_details financial_assessment]
    else
      %i[client_details]
    end
  rescue ActiveRecord::RecordNotFound, NameError
    []
  end

  # TODO: this relies on ApplicationDependable making the legal_aid_application method a helper_method,
  # which is not a good solution from a maintenance point of view.
  # This requires a handler for NameError if the controller does not have ApplicationDependable included,
  # and ActiveRecord::RecordNotFound if the pages, such as select_office, has no application id.
  #
  def merits_sidebar_items
    if legal_aid_application.non_passported?
      %i[client_details financial_assessment capital_and_assets]
    elsif legal_aid_application.passported?
      %i[client_details capital_and_assets]
    else
      %i[client_details]
    end
  rescue ActiveRecord::RecordNotFound, NameError
    []
  end

  def all_sidebar_items
    merits_sidebar_items + [:merits]
  end
end
