Feature: Checking ccms means does NOT auto grant 

 @javascript
 Scenario: I am able to create a passported application with Cap Contribs > £3k and with restrictions
   Given the setting to manually review all cases is enabled
   And I previously created a passported application and left on the "savings_and_investment" page
   Then I visit the applications page
   And I save and open page
   Then I view the previously created application
