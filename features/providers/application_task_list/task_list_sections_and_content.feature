@javascript
Feature: Application task list page sections, subsections and content

  Background:
    Given I am logged in as a provider

  Scenario: I can view the application task list's basic information
    Given I have completed an application as far national insurance number

    When I go to the application task list
    Then I should be on a page with title "Make a new application"
    And I should see "Use this list to see your progress"
    And I should see "You can go back and edit completed sections if they appear as links. More sections will become editable over time."

  Scenario: I can view the application task list in it's initial state
    Given I have completed an application as far national insurance number

    When I go to the application task list
    Then I should see section header "1. Client and case details"
    And I should see section header "2. Means test"
    And I should see "We may ask you later about your client's income, outgoings, savings, investments, assets, payments and dependants, if it's needed"
    And I should see section header "3. Merits"
    And I should see "Once the proceedings have been selected, the relevant tasks will appear in this section."
    And I should see section header "4. Confirm and submit"

  Scenario: I can view the application task list in it's passported state
    Given I complete the passported journey as far as check your answers for client details
    When I go to the application task list
    Then I should see subsection header "Financial information"
    And I should see "You do not need to give financial information because DWP records show that your client gets a passporting benefit."
    And I should see subsection header "Capital and assets"
    And I should see subsection header "About this application"
    And I should see subsection header "About the proceedings"
    And I should see subsection header "Supporting evidence and review"

