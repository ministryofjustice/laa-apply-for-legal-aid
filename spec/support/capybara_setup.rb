require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new(args: %w[start-maximized headless disable-gpu no-sandbox])
  chrome_options = {
    browser: :chrome,
    options: browser_options
  }

  Capybara::Selenium::Driver.new app, chrome_options.merge(clear_local_storage: true, clear_session_storage: true)
end

# Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome
