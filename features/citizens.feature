Feature: Citizen page

# NOTE: There is an issue with FactoryBot attempting to setup
# an application and cucumber scenario run not recognising it.
# We were unable to determine the cause of it. Needs re-visiting.
# Scenario: Successfully navigate through an application
#   Given a solicitor has created an application
#   And I am on the citizen start page for that application
#   Then I see "Complete your legal aid financial assessment"
#   And I see the start link
#   When I click the start link
#   Then I see the open banking information page
#   When I click the continue link
#   Then I see the consent page
#   When I click the back link
#   Then I see the open banking information page
#   When I click the back link
#   Then I see the start page
