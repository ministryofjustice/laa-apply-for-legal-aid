When("I have completed a non-passported application and reached the evidence upload page") do
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

When("I have completed a non-passported application and reached the statement of case upload page") do
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
  visit(providers_legal_aid_application_statement_of_case_path(@legal_aid_application))
end

Then(/^I upload an evidence file named ['|"](.*?)['|"]/) do |filename|
  attach_file(Rails.root.join("spec/fixtures/files/documents/#{filename}"), class: "dz-hidden-input", make_visible: true, wait: 30)
end

Then(/^I upload the fixture file named ['|"](.*?)['|"]/) do |filename|
  attach_file(Rails.root.join("spec/fixtures/files/#{filename}"), class: "dz-hidden-input", make_visible: true, wait: 30)
end

Then(/^I should be able to categorise ['|"](.*?)['|"] as ['|"](.*?)['|"]$/) do |filename, category|
  find(:xpath, "//td[text()='#{filename}']/following-sibling::td//select/option[text()=\"#{category}\"]").select_option
end

Then(/^I click delete for the file ['|"](.*?)['|"]/) do |filename|
  find(:xpath, "//td[text()='#{filename}']/following-sibling::td//button[contains(@class,'button-as-link')]").click
end

Given("csrf is enabled") do
  ActionController::Base.allow_forgery_protection = true
end

And("I should see {int} uploaded files") do |int|
  sleep 1
  delete_buttons = find_all(:xpath, "//td//button[contains(@class,'button-as-link')]")
  expect(delete_buttons.count).to eq int
end
