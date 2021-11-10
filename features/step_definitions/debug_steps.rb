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

When(/^I display the setup$/) do
  puts ">>>>>>>>>>>> LegalAidAppliation count: #{LegalAidApplication.count} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  laa = LegalAidApplication.first
  puts ">>>>>>>>>>>> id: #{laa.id} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  puts ">>>>>>>>>>>> proceeding types #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  ap ProceedingType.order(:ccms_code).pluck(:ccms_code, :id)
  puts ">>>>>>>>>>>> apts #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  ap laa.application_proceeding_types
  puts ">>>>>>>>>>>> proceeeding types linked to application #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  ap laa.application_proceeding_types.map(&:proceeding_type)
  puts ">>>>>>>>>>>> proceedings #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  ap laa.proceedings
  puts ">>>>>>>>>>>> end of setup #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
end

# TODO: remove after LFA migration complete
When(/^I enable callbacks on ApplicationProceedingType$/) do
  ApplicationProceedingType.set_callback(:create, :after, :create_proceeding)
  ApplicationProceedingType.set_callback(:update, :after, :update_proceeding)
  ApplicationProceedingType.set_callback(:destroy, :before, :destroy_proceeding)
end

# TODO: remove after LFA migration complete
When(/^I disable callbacks on ApplicationProceedingType$/) do
  ApplicationProceedingType.skip_callback(:create, :after, :create_proceeding, raise: false)
  ApplicationProceedingType.skip_callback(:update, :after, :update_proceeding, raise: false)
  ApplicationProceedingType.skip_callback(:destroy, :before, :destroy_proceeding, raise: false)
end
