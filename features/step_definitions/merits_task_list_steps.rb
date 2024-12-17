Given("I complete the journey as far as merits task list for a PLF proceeding with second appeal question") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_means_tested_state_machine,
    :with_positive_benefit_check_result,
    :with_proceedings,
    :with_applicant,
    :provider_entering_merits,
    explicit_proceedings: %i[pbm01a],
    set_lead_proceeding: :pbm01a,
  )
  create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application: @legal_aid_application)

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_merits_task_list_path(@legal_aid_application))
end
