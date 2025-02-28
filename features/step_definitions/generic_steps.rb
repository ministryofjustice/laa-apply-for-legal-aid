Then("I should be on a page with title {string}") do |title|
  expect(page).to have_title(title)
end

Then("I should be on a page with title matching {string}") do |title|
  expect(page).to have_title(/#{title}/)
end

Then("I should see a link with text {string}") do |locator|
  expect(page).to have_link(locator)
end

Then("I should see govuk error summary {string}") do |error_text|
  summary = page.find("div.govuk-error-summary > div[role='alert']")
  expect(summary).to have_css(
    "h2",
    class: "govuk-error-summary__title",
    text: "There is a problem",
  )
  expect(summary).to have_link(error_text)
end

Then("I should see govuk-details {string}") do |text|
  expect(page).to have_css(".govuk-details", text:)
end

Then("I should see govuk-tag {string}") do |text|
  expect(page).to have_css(".govuk-tag", text:)
end

Then("I should see govuk-notification-banner {string}") do |text|
  expect(page)
    .to have_css(".govuk-notification-banner", text: /#{text}/),
        "expected to find govuk-notification-banner with text matching: \"#{text}\""
end

And(/^I should (see|not see) a ['|"](.*?)['|"] button$/) do |visibility, text|
  if visibility == "see"
    expect(page).to have_button(text:)
  else
    expect(page).to have_no_button(text:)
  end
end

Then("the following sections should exist:") do |table|
  table.hashes.each do |row|
    expect(page).to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the following sections within {string} should exist:") do |individual, table|
  table.hashes.each do |row|
    within("section.#{individual}") do
      expect(page).to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
    end
  end
end

Then("the following sections should not exist:") do |table|
  table.hashes.each do |row|
    expect(page).not_to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected not to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the govuk-summary-card titled {string} should contain:") do |card_title, table|
  element = page.find(class: "govuk-summary-card", text: card_title)

  expect_questions_and_answers_in(selector: element[:id].prepend("#"), expected: table)
end

When("I click the govuk-summary-card titled {string} Change link") do |card_title|
  element = page.find(class: "govuk-summary-card", text: card_title)

  within("#{element[:id].prepend('#')} .govuk-summary-card__action") do
    click_on "Change"
  end
end

Given("I insert cassette {string}") do |string|
  VCR.insert_cassette(string, record: :once, allow_playback_repeats: true)
end

Then("I should not see any change links") do
  expect(page).to have_no_link("Change")
end

def expect_questions_in(expected:, selector:, negate: false)
  within(selector) do
    expected.hashes.each do |row|
      if negate
        expect(page).not_to have_css("dt", text: row[:question]), "expected not to find tag \"dt\" with text: \"#{row[:question]}\""
      else
        expect(page).to have_css("dt", text: row[:question]), "expected to find tag \"dt\" with text: \"#{row[:question]}\""
      end
    end
  end
end

def expect_questions_and_answers_in(expected:, selector:)
  within(selector) do
    expected.hashes.each do |row|
      expect(page).to have_css("dt", text: row[:question]), "expected to find tag \"dt\" with text: \"#{row[:question]}\""
      expect(page).to have_css("dd", text: row[:answer]), "expected to find tag \"dd\" with text: \"#{row[:answer]}\""
    end
  end
end

def expect_questions_and_answers_in_table(expected:, selector:)
  within(selector) do
    expected.hashes.each do |row|
      expect(page).to have_css("th", text: row[:question]), "expected to find tag \"th\" with text: \"#{row[:question]}\""
      expect(page).to have_css("td", text: row[:answer]), "expected to find tag \"td\" with text: \"#{row[:answer]}\""
    end
  end
end
