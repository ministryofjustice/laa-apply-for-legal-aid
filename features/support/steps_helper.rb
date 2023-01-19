Then("I debug the response body") do
  fn = Rails.root.join("tmp/debug.html")
  puts ">>>>>>>>>>>> #{__FILE__}:#{__LINE__} output HTML file://#{fn}".yellow
  File.open(fn, "w") { |fp| fp.puts page.body }
  puts ">>>>>>>>>>>> #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
end

Then("I print the response body html") do
  puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  puts page.body
  puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
end

Then("I should be on a page showing {string}") do |title|
  expect(page).to have_content(title)
end

Then("I should be on a page showing {string} with a date of {int} days ago using {string} format") do |title, num_days, format|
  expect(page).to have_content("#{title} #{num_days.days.ago.strftime(format)}")
end

Then("I should be on the {string} page showing {string}") do |view_name, title|
  expect(page.current_path).to end_with(view_name)
  expect(page).to have_content(/#{title.starts_with?('?') ? title.gsub('?', '[?]') : title}/)
end

Then("I should be on a page not showing {string}") do |title|
  expect(page).not_to have_content(title)
end

Then("I choose {string}") do |option|
  choose(option, allow_label_click: true)
end

Then("I click link {string}") do |link_name|
  click_link(link_name)
end

Then("I click the {string} link {int} times") do |link_name, number|
  number.times { click_link(link_name) }
end

Then("I click the first link {string}") do |link_name|
  first(:link, link_name).click
end

Then("I click the {string} link {string}") do |nth, link_name|
  all(:link, link_name)[nth.to_i - 1].click
end

Then("I click the last link {string}") do |link_name|
  all(:link, link_name).last.click
end

Then("I open the section {string}") do |section|
  section = page.find(".govuk-details__summary-text", text: section)
  section.click
end

Then("I select {string}") do |option|
  check(option, allow_label_click: true)
end

Then("I deselect {string}") do |option|
  uncheck(option, allow_label_click: true)
end

Then("I click {string}") do |button_name|
  click_button(button_name)
end

Then("I click {string} {int} times") do |button_name, number|
  number.times { click_button(button_name) }
end

Then("I scroll down") do
  page.execute_script "window.scrollBy(0,10000)"
end

Then("I temporarily resize browser window to width {int} height {int} and click {string}") do |width, height, link|
  dimensions = page.driver.browser.manage.window.size
  page.driver.browser.manage.window.resize_to(width, height)
  click_link(link)
  page.driver.browser.manage.window.resize_to(*dimensions)
end

# Search name and id attributes of input and textarea elements which contain the field string
# Match examples:
# <input name=field ... >
# <input name=string[field] ... >
# <textarea name=string[field] ... >
# <input id=field ... >
Then("I fill {string} with {string}") do |field, value|
  field.downcase!
  field_id = field.gsub(/\s+/, "-")
  field.gsub!(/\s+/, "_")
  name = find("input[name*=#{field}], textarea[name*=#{field}], ##{field_id}")[:name]
  fill_in(name, with: value)
end

Then("I reload the page") do
  visit current_path
end

Then("I choose option {string}") do |field|
  choose(field.parameterize(separator: "-"), allow_label_click: true)
end

# This can be used to display the state of the application
# Usage:
# Then I display the state of the application from 123
#
Then("I display the state of the application from {int}") do |label|
  if @legal_aid_application.nil?
    raise "Unable to determine the application to be displayed" if LegalAidApplication.count != 1

    @legal_aid_application = LegalAidApplication.first
  end
  puts ">>>>>>>>>>>> #{label} #{@legal_aid_application.reload.state} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
end
