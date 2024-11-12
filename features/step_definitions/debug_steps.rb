# rubocop:disable Lint/Debugger
When("I bind and pry") do
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
  value = enabled.eql?("enabled")
  Setting.setting.update!("#{flag}": value)
end

And(/^the provider has SCA permissions$/) do
  # TODO: Remove when removing Setting.special_children_act
  sca_permission = Permission.find_by(role: "special_children_act") || create(:permission, :special_children_act)
  @registered_provider.firm.permissions << sca_permission
end

And(/^the MTR-A start date is in the past$/) do
  # TODO: Remove when removing Setting.means_test_review_a
  allow(Rails.configuration.x).to receive(:mtr_a_start_date).and_return(Date.yesterday)
end

When(/^I sleep for (.*?) seconds$/) do |num_secs|
  sleep num_secs.to_i
end
