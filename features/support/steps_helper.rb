Then('I should be on a page showing {string}') do |title|
  expect(page).to have_content(title)
end

Then('I choose {string}') do |option|
  choose(option, allow_label_click: true)
end

Then('I click link {string}') do |link_name|
  click_link(link_name)
end

Then('I select {string}') do |option|
  check(option, allow_label_click: true)
end

Then('I deselect {string}') do |option|
  uncheck(option, allow_label_click: true)
end

Then('I click {string}') do |button_name|
  click_button(button_name)
end

Then('I fill {string} with {string}') do |field, value|
  fill_in(field.parameterize(separator: '_'), with: value)
end

Then('I upload a pdf file') do
  attach_file('Attach a file', Rails.root.join('spec/fixtures/files/documents/hello_world.pdf'))
end
