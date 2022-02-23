When('I have completed a non-passported application and reached the evidence upload page') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_proceedings, explicit_proceedings: %i[se014 da001]
  )
  create :dwp_override, :with_evidence, legal_aid_application: @legal_aid_application
  create :legal_framework_merits_task_list, legal_aid_application: @legal_aid_application
  create :uploaded_evidence_collection, :with_multiple_files_attached, legal_aid_application: @legal_aid_application
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_uploaded_evidence_collection_path(@legal_aid_application))
end

Then('I upload an evidence file') do
  attach_file('Attach a file', Rails.root.join('spec/fixtures/files/documents/hello_world.pdf'))
end

Then(/^I should be able to categorise ['|"](.*?)['|"] as ['|"](.*?)['|"]$/) do |filename, category|
  find(:xpath, "//td[text()='#{filename}']/following-sibling::td//select/option[text()='#{category}']").select_option
end
