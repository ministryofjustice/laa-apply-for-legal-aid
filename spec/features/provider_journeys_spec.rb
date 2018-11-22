require 'rails_helper'

RSpec.describe 'Provider application journeys', type: :feature do
  before do
    Rails.application.load_seed
  end

  scenario 'Provider able to clear proceeding on the proceeding page', js: true, vcr: true do
    visit providers_root_path
    check_page_accessibility

    click_link 'Start'
    check_page_accessibility

    click_link 'Start now'
    check_page_accessibility

    fill_in 'proceeding-search-input', with: 'app'
    wait_for_ajax
    expect(page).to have_css('#proceeding-list > .proceeding-item')
    check_page_accessibility

    page.find('#clear-proceeding-search').click
    expect(page).to have_field('proceeding-search-input', with: '')
    expect(page).to_not have_css('#proceeding-list > .proceeding-item')

    fill_in 'proceeding-search-input', with: 'Application for a care order'
    wait_for_ajax

    find('#proceeding-list').first(:button, 'Select and continue').click
    check_page_accessibility

    fill_in 'first_name', with: 'Test'
    fill_in 'last_name', with: 'User'
    fill_in 'dob_day', with: '03'
    fill_in 'dob_month', with: '04'
    fill_in 'dob_year', with: '1999'
    fill_in 'national_insurance_number', with: 'CB987654A'

    click_button 'Continue'
    expect(page).to have_content("Enter your client's home address")
    check_page_accessibility

    fill_in 'postcode', with: 'DA74NG'

    click_button 'Find address'
    check_page_accessibility

    select('3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG', from: 'address_selection[address]')

    click_button 'Continue'
    expect(page).to have_content("Your client's tax and benefits status")
    check_page_accessibility

    click_button 'Continue'
    check_page_accessibility

    fill_in 'email', with: 'test@test.com'

    click_button 'Continue'
    check_page_accessibility

    click_button 'Continue'
    check_page_accessibility

    print_accessibility_report
  end
end
