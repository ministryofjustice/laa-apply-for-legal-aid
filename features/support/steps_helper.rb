Then('I should be on a page showing {string}') do |title|
  expect(page).to have_content(title)
end

Then('I should be on a page showing {string} with a date of {int} days ago using {string} format') do |title, num_days, format|
  expect(page).to have_content("#{title} #{num_days.days.ago.strftime(format)}")
end

Then('I should be on the {string} page showing {string}') do |view_name, title|
  expect(page.current_path).to end_with(view_name)
  expect(page).to have_content(/#{title.starts_with?('?') ? title.gsub('?', '[?]') : title}/)
end

Then('I should be on a page not showing {string}') do |title|
  expect(page).not_to have_content(title)
end

Then('I choose {string}') do |option|
  choose(option, allow_label_click: true)
end

Then('I click link {string}') do |link_name|
  click_link(link_name)
end

Then('I click the first link {string}') do |link_name|
  first(:link, link_name).click
end

Then('I click the last link {string}') do |link_name|
  all(:link, link_name).last.click
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

Then('I scroll down') do
  page.execute_script 'window.scrollBy(0,10000)'
end

# Search name and id attributes of input and textarea elements which contain the field string
# Match examples:
# <input name=field ... >
# <input name=string[field] ... >
# <textarea name=string[field] ... >
# <input id=field ... >
Then('I fill {string} with {string}') do |field, value|
  field.downcase!
  field_id = field.gsub(/\s+/, '-')
  field.gsub!(/\s+/, '_')
  name = find("input[name*=#{field}], textarea[name*=#{field}], ##{field_id}")[:name]
  fill_in(name, with: value)
end

Then('I upload a pdf file') do
  attach_file('Attach a file', Rails.root.join('spec/fixtures/files/documents/hello_world.pdf'))
end

Then('I reload the page') do
  visit current_path
end

Then('I choose option {string}') do |field|
  choose(field.parameterize(separator: '-'), allow_label_click: true)
end

# This can be used to display the state of the application
# Usage:
# Then I display the state of the application from 123
#
Then('I display the state of the application from {int}') do |label|
  if @legal_aid_application.nil?
    raise 'Unable to determine the application to be displayed' if LegalAidApplication.count != 1

    @legal_aid_application = LegalAidApplication.first
  end
  puts ">>>>>>>>>>>> #{label} #{@legal_aid_application.reload.state} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
end
