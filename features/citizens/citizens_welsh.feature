Feature: Citizen journey in Welsh

  @javascript
  Scenario: Start citizen journey until TrueLayer Auth
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment in Welsh
    Then I should be on a page showing 'noitacilppa dia lagel ruoY'
    Then I click link 'tratS'
    Then I should be on a page showing "?reyaLeurT aiv >rbba/'ycnegA diA lageL'=eltit rbba< eht htiw stnemetats knab fo shtnom 3 erahs ot eerga uoy oD"
    Then I choose 'seY'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'knab ruoy tceleS'
    Then I should be on a page showing ".sknab tnereffid htiw stnuocca evah uoy fi retal erom tceles ot elba eb ll'uoY .emit a ta knab eno tceleS"
    Then I click link 'kcaB'
    Then I should be on a page showing "?reyaLeurT aiv >rbba/'ycnegA diA lageL'=eltit rbba< eht htiw stnemetats knab fo shtnom 3 erahs ot eerga uoy oD"
    Then I choose 'oN'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'noitacilppa ruoy eunitnoc ot roticilos ruoy tcatnoC'
    Then I click link 'kcaB'
    Then I should be on a page showing "?reyaLeurT aiv >rbba/'ycnegA diA lageL'=eltit rbba< eht htiw stnemetats knab fo shtnom 3 erahs ot eerga uoy oD"
    Then I choose 'seY'
    Then I click 'eunitnoc dna evaS'
    Then I choose 'HSBC'
    Then I click 'eunitnoc dna evaS'
    Then I am directed to TrueLayer
    When I click the browser back button
    Then I return to English

  @javascript @vcr
  Scenario: Follow citizen journey from Accounts page
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I visit the accounts page
    Then I click link 'Cymraeg'
    Then I click link 'eunitnoC'
    Then I should be on a page showing '?sknab rehto htiw stnuocca evah uoy oD'
    Then I choose 'seY'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing '?enilno ssecca tonnac uoy stnuocca tnerruc evah uoy oD'
    Then I choose 'seY'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'roticilos ruoy tcatnoC'
    Then I click link 'kcaB'
    Then I should be on a page showing '?enilno ssecca tonnac uoy stnuocca tnerruc evah uoy oD'
    Then I choose 'oN'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'knab ruoy tceleS'
    Then I click link 'kcaB'
    Then I click link 'kcaB'
    Then I should be on a page showing '?sknab rehto htiw stnuocca evah uoy oD'
    Then I choose 'oN'
    Then I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'srewsna ruoy kcehC'
    Then I should be on a page showing 'gniwollof eht mrifnoC'
    Then I click 'timbus dna eergA'
    Then I should be on a page showing "noitamrofni laicnanif ruoy derahs ev'uoY"
    Then I click the browser back button
    Then I should be on a page showing "tnemssessa laicnanif ruoy detelpmoc ydaerla ev'uoY"
    Then I return to English

  @javascript @vcr
  Scenario: View privacy policy
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'ycilop ycavirP'
    Then I should be on a page showing 'Purpose'
    Then I return to English

  @javascript @vcr
  Scenario: View contact information
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'tcatnoC'
    Then I should be on a page showing 'su tcatnoC'
    Then I return to English

  @javascript @vcr
  Scenario: View accessibility statement
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'tnemetats ytilibisseccA'
    Then I should be on a page with title 'Accessibility statement for Apply for civil legal aid service (Welsh placeholder)'
    Then I should be on a page showing 'How you should be able to use this website'
    Then I return to English

  @javascript @vcr
  Scenario: Visit the feedback page
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'kcabdeeF'
    Then I should be on a page with title "[Welsh] Help us improve the Apply for civil legal aid service"
    Then I return to English
