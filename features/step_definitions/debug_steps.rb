# rubocop:disable Lint/Debugger
When('I bind and pry') do
  binding.pry
end

When(/^I save and open page$/) do
  save_and_open_page
end
# rubocop:enable Lint/Debugger

When(/^I save and open screenshot$/) do
  screenshot_and_open_image
end
