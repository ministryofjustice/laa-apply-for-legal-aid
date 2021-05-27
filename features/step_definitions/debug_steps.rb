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

When(/^the feature flag for (.*?) is (enabled|disabled)$/) do |flag, enabled|
  value = enabled.eql?('enabled')
  Setting.setting.update!("#{flag}": value)
end

When(/^the method (.*?) of (.*?) is rerun$/) do |method, klass|
  klass.classify.constantize.send(method)
end
