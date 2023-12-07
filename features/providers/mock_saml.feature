Feature: Mock saml test
  @javascript
  Scenario: A provider can login with mock saml data
    Given I visit the root page
    And I click link 'start'
    When I enter the email address 'test1@example.com'
    And I enter the password 'password'
    And I submit to saml
    Then I should be on the '/' page showing 'Civil and family legal aid providers can use this service to apply for civil legal aid'
