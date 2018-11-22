require 'rails_helper'

RSpec.describe 'Provider application journeys', type: :feature do
  scenario 'Provider able to clear proceeding on the proceeding page', js: true do
    visit providers_root_path

    puts page.current_url
    report = page.execute_script('var results = axs.Audit.run();return axs.Audit.createReport(results);')
    puts report
    click_link 'Start'
    print page.current_url
    report = page.execute_script('var results = axs.Audit.run();return axs.Audit.createReport(results);')
    print report
    click_link 'Start now'
    puts page.current_url
    report = page.execute_script('var results = axs.Audit.run();return axs.Audit.createReport(results);')
    print report
    fill_in 'proceeding-search-input', with: 'app'
  end
end
