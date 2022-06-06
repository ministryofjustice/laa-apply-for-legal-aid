Then("I should be on a page with title {string}") do |title|
  expect(page).to have_title(title)
end
