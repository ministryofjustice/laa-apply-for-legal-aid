Then("I should be on a page with title {string}") do |title|
  expect(page).to have_title(title)
end

Then("I should be on a page with title matching {string}") do |title|
  expect(page).to have_title(/#{title}/)
end

Then("I should see govuk error summary {string}") do |error_text|
  summary = page.find('.govuk-error-summary[role="alert"]')
  expect(summary).to have_selector("#error-summary-title", text: "There is a problem")
  expect(summary).to have_link(error_text)
end

Then("I should see govuk-details {string}") do |text|
  expect(page).to have_selector(".govuk-details", text:)
end
