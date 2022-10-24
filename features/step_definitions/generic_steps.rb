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

Then("the following sections should exist:") do |table|
  table.hashes.each do |row|
    expect(page).to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the following sections should not exist:") do |table|
  table.hashes.each do |row|
    expect(page).not_to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected not to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end
