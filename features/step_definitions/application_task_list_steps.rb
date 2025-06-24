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

Given("I created a passported application") do
  @legal_aid_application = create(:legal_aid_application, :with_proceedings)
  create(:benefit_check_result, :positive, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
end

Given("I created a non-passported application") do
  @legal_aid_application = create(:legal_aid_application, :with_proceedings)
  create(:benefit_check_result, :negative, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
end

Given("I created a non-means-tested application") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_under_18_applicant,
  )

  create :legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

When("I go to the application task list") do
  @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
  visit providers_legal_aid_application_task_list_path(@legal_aid_application)
end

Then("I should see section header {string}") do |text|
  expect(page).to have_css("h2.govuk-task-list__section", text:)
end

Then(/^I should (see|not see) subsection header (.*)$/) do |visibility, text|
  text = text.delete_prefix('"').delete_suffix('"')

  if visibility == "see"
    expect(page).to have_css("h3.govuk-task-list__section", text:)
  else
    expect(page).to have_no_css("h3.govuk-task-list__section", text:)
  end
end

Then("the {string} task list section should contain:") do |text, table|
  heading = page.find("h2.govuk-task-list__section", text:)
  section_list = heading.ancestor("li")

  within(section_list) do
    table.hashes.each do |row|
      expect(page).to have_css(".govuk-task-list__name-and-hint", text: row[:name])
      expect(page).to have_link(row[:name]) if row[:link_enabled].downcase.eql?("true")
      expect(page).to have_css(".govuk-task-list__status", text: row[:status])
    end
  end
end

def id_from_current_page_url
  path = URI.parse(page.current_url).path
  paths = path.split("/").reject! { |fragment| fragment.to_s.empty? }
  id_at = paths.find_index("applications")
  return paths[id_at + 1] if id_at

  raise "Unable to locate LegalAidApplication ID accurately"
end
