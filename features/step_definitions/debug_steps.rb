When('I bind and pry') do
  binding.pry
end

When(/^I save and open page$/) do
  save_and_open_page
end

When(/^I save and open screenshot$/) do
  screenshot_and_open_image
end
