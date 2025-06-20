Given("I have completed an application as far national insurance number") do
  @legal_aid_application = create(
    :application,
    provider_step: "has_national_insurance_numbers",
    provider: @registered_provider,
    applicant: build(:applicant,
                     first_name: "John",
                     last_name: "Doe",
                     date_of_birth: 21.years.ago,
                     has_national_insurance_number: nil,
                     national_insurance_number: nil),
  )
end

# Given("I have completed an application as far as DWP outcome for a passported application") do
#   @legal_aid_application = create(
#     :application,
#     provider_step: "has_national_insurance_numbers",
#     provider: @registered_provider,
#     applicant: build(:applicant,
#                      first_name: "John",
#                      last_name: "Doe",
#                      date_of_birth: 21.years.ago,
#                      has_national_insurance_number: nil,
#                      national_insurance_number: nil
#                      proceedings),
#   )
# end

When("I go to the application task list") do
  visit providers_legal_aid_application_task_list_path(@legal_aid_application)
end

Then("I should see section header {string}") do |text|
  expect(page).to have_css("h2.govuk-task-list__section", text:)
end

Then("I should see subsection header {string}") do |text|
  expect(page).to have_css("h3.govuk-task-list__section", text:)
end
