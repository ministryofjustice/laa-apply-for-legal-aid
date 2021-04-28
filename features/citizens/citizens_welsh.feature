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
    Then I click 'eunitnoC'
    Then I should be on a page showing 'knab ruoy tceleS'
    Then I should be on a page showing ".sknab tnereffid htiw stnuocca evah uoy fi retal erom tceles ot elba eb ll'uoY .emit a ta knab eno tceleS"
    Then I click link 'kcaB'
    Then I should be on a page showing "?reyaLeurT aiv >rbba/'ycnegA diA lageL'=eltit rbba< eht htiw stnemetats knab fo shtnom 3 erahs ot eerga uoy oD"
    Then I choose 'oN'
    Then I click 'eunitnoC'
    Then I should be on a page showing 'noitacilppa ruoy eunitnoc ot roticilos ruoy tcatnoC'
    Then I click link 'kcaB'
    Then I should be on a page showing "?reyaLeurT aiv >rbba/'ycnegA diA lageL'=eltit rbba< eht htiw stnemetats knab fo shtnom 3 erahs ot eerga uoy oD"
    Then I choose 'seY'
    Then I click 'eunitnoC'
    Then I choose 'HSBC'
    Then I click 'eunitnoC'
    Then I am directed to TrueLayer

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
    Then I should be on a page showing 'eviecer uoy od stnemyap gniwollof eht fo hcihW'
    And I select 'eseht fo enoN'
    Then I click 'eunitnoc dna evaS'
    Then I should be on the 'student_finance' page showing '?ecnanif tneduts teg uoy oD'
    When I choose 'seY'
    And I click 'eunitnoc dna evaS'
    Then I should be on the 'annual_amount' page showing '?raey cimedaca siht teg uoy lliw ecnanif tneduts hcum woH'
    When I enter amount '5000'
    And I click 'eunitnoc dna evaS'
    Then I should be on a page showing '?ekam uoy od stnemyap gniwollof eht fo hcihW'
    Then I select 'stnemyap gnisuoH'
    Then I click 'eunitnoc dna evaS'
    Then I should be on the 'cash_outgoing' page showing 'hsac ni ekam uoy stnemyap tceleS'
    Then I select 'stnemyap gnisuoH'
    Then I enter rent_or_mortgage1 '100'
    Then I enter rent_or_mortgage2 '100'
    Then I enter rent_or_mortgage3 '100'
    And I click 'eunitnoc dna evaS'
    Then I should be on a page showing 'srewsna ruoy kcehC'
    Then I should be on a page showing 'gniwollof eht mrifnoC'
    Then I click 'timbus dna eergA'
    Then I should be on a page showing "noitamrofni laicnanif ruoy derahs ev'uoY"
    Then I click the browser back button
    Then I should be on a page showing "tnemssessa laicnanif ruoy detelpmoc ydaerla ev'uoY"

  @javascript @vcr
  Scenario: View privacy policy
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'ycilop ycavirP'
    Then I should be on a page showing 'esopruP'

  @javascript @vcr
  Scenario: View contact information
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'tcatnoC'
    Then I should be on a page showing 'su tcatnoC'

  @javascript @vcr
  Scenario: View accessibility statement
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'tnemetats ytilibisseccA'
    Then I should be on a page showing 'ecivres siht gnisU'

  @javascript @vcr
  Scenario: Visit the feedback page
    Given An application has been created
    Then I visit the start of the financial assessment in Welsh
    Then I click link 'kcabdeeF'
    Then I should be on a page showing '?ecivres siht esu ot ti saw tluciffid ro ysae woH'
