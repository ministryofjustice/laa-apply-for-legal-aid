# RSpec system test configuration only.
#
# For javascript reliant system tests
# you can use js: true
# e.g.
# it "does something dependent on javascript", js: true do
#   visit "/"
#   expect(page).to have...
# end
#
# For non-JS dependent tests exclude the js: metadata
# e.g.
# $ describe "my non-JS dependent test" do...
#
# For running tests in chrome (non-headless) you can set BROWSER envvar
# e.g.
# $ BROWSER=true rspec spec/system
#
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include LoginHelpers, type: :system
  config.include ScreenshotHelpers, type: :system
  config.include GovukFormHelpers, type: :system
  config.include CapybaraHelpers, type: :system
  config.include TaskListHelpers, type: :system
  config.include StepHelpers, type: :system

  config.before(:each, type: :system) do |example|
    if ENV["BROWSER"].present?
      driven_by :chrome
    elsif example.metadata[:js]
      driven_by :headless_chrome
    else
      driven_by :rack_test
    end
  end

  config.after(:each, type: :system) do |example|
    if example.exception &&
        (example.metadata[:js] || ENV["BROWSER"].present?)
      abort browser_logs
    end
  end

  config.before(:each, :js, type: :system) do
    driven_by :headless_chrome
  end

  # config.after(:each, :js, type: :system) do
  #   do-some-clearup
  # end

  def browser_logs
    <<~BROWSER_LOGS
      ======== START OF BROWSER LOGS ========
      #{page.driver.browser.logs.get(:browser).join("\n")}
      ======== END OF BROWSER LOGS   ========
    BROWSER_LOGS
  end
end
