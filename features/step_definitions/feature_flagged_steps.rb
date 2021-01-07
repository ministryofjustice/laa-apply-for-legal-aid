Then('I complete the policy disregards page with data if needed') do
  if Time.zone.now > Rails.configuration.x.policy_disregards_start_date
    steps %(
      Then I should be on the 'policy_disregards' page showing 'schemes or charities'
      Then I select 'England Infected Blood Support Scheme'
      And the page is accessible
      Then I click 'Save and continue'
    )
  end
  # TODO: After the go live date, replace uses of this step with the ones included in the array
end

Then('I return though the policy_disregards page if needed') do
  if Time.zone.now > Rails.configuration.x.policy_disregards_start_date
    steps %(
      Then I should be on the 'policy_disregards' showing 'schemes or charities'
      Then I click link "Back"
    )
  end
  # TODO: After the go live date, replace uses of this step with the ones included in the array
end

Then('I click {string} if needed') do |button_name|
  click_button(button_name) if Time.zone.now > Rails.configuration.x.policy_disregards_start_date
  # TODO: After the go live date, remove uses of this step and replace with just `click_button(button_name)`
end
