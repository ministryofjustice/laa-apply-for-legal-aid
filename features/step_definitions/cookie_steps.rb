Given("I have not yet updated my cookie preferences") do
  @registered_provider.update(cookies_enabled: nil)
end

Given("I start the journey without cookie preferences") do
  steps %(
    Given I am logged in as a provider
    And I have not yet updated my cookie preferences

    When I visit the application service
    And I click link "Start"
    Then I choose '0X395U'
    Then I click 'Save and continue'
    Then I am on the legal aid applications page
    And I should see 'Cookies on Apply for civil legal aid'
  )
end

Given("I have expired cookie preferences") do
  @registered_provider.update(cookies_enabled: true, cookies_saved_at: 1.year.ago - 1.day)
end

Given("I start the journey with expired cookie preferences") do
  steps %(
    Given I am logged in as a provider
    And I have expired cookie preferences

    When I visit the application service
    And I click link "Start"
    Then I choose '0X395U'
    Then I click 'Save and continue'
    Then I am on the legal aid applications page
    And I should see 'Cookies on Apply for civil legal aid'
  )
end
