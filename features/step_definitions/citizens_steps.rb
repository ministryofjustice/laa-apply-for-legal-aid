Then('I see {string}') do |string|
  page.should have_content(string)
end

Then('I see the start link') do
  page.find('#start')
end

Given('a solicitor has created an application') do
  @application_ref = legal_aid_application.application_ref
end

And('I am on the citizen start page for that application') do
  visit("citizens/legal_aid_applications/#{@application_ref}")
end

When('I click the start link') do
  click_link('Start')
end

Then('I see the consent page') do
  page.find('#open-banking-consent')
end

When('I click the back link') do
  click_link('Back')
end

Then('I see the start page') do
  page.find('#start')
end

Then('I see the open banking information page') do
  page.should have_content('Give one-time access to your bank accounts')
end

When('I click the continue link') do
  click_link('Continue')
end

def legal_aid_application
  @legal_aid_application = FactoryBot.create :application, :with_applicant
end
