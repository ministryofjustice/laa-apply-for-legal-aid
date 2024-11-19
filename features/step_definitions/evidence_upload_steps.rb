When("I have completed a non-passported application and reached the evidence upload page") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :with_domestic_abuse_summary,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_incident,
    :with_chances_of_success,
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

Then("I select a category of {string} for the file {string}") do |category, filename|
  within("tr", text: filename) do
    select(category)
  end
end

Then("I should see the file {string} categorised as {string}") do |filename, category|
  within("tr", text: filename) do
    expect(page).to have_select("Select a category", selected: category)
  end
end

Then("I click delete for the file {string}") do |filename|
  within("tr", text: filename) do
    click_link_or_button("Delete")
  end
end

Given("csrf is enabled") do
  ActionController::Base.allow_forgery_protection = true
end

And("I should see {int} uploaded files") do |int|
  sleep 1
  delete_buttons = find_all(:xpath, "//td//button[contains(@class,'button-as-link')]")
  expect(delete_buttons.count).to eq int
end
