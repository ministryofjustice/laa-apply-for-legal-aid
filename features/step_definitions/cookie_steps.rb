Given("I have not yet updated my cookie preferences") do
  @registered_provider.update(cookies_enabled: nil)
end

Given("I start the journey without cookie preferences") do
  steps %(
    Given I am logged in as a provider
    And I have not yet updated my cookie preferences

    When I visit the application service
    And I click link "Start"
    Then I am on the legal aid applications page
    And I should see 'Cookies on Apply for legal aid'
  )
end
