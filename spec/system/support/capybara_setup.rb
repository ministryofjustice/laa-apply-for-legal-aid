# Selenium logging
# https://www.selenium.dev/documentation/webdriver/troubleshooting/logging/#ruby
# other args in order of decreasing verbosity\
# :debug, :info, :warn (default), :error, :fatal
Selenium::WebDriver.logger.level = :warn

# We use a Capybara default value here explicitly.
Capybara.default_max_wait_time = 5

# Normalize whitespaces when using `has_text?` and similar matchers,
# i.e., ignore newlines, trailing spaces, etc.
# That makes tests less dependent on slight UI changes.
Capybara.default_normalize_ws = true

# Where to store system tests artifacts (e.g. screenshots, downloaded files, etc.).
# It could be useful to be able to configure this path from the outside (e.g., on CI).
Capybara.save_path = ENV.fetch("CAPYBARA_ARTIFACTS", "./tmp/capybara")

# Register drivers with options
Capybara.register_driver :headless_chrome do |app|
  args = %w[start-maximized headless disable-gpu disable-gpu no-sandbox disable-site-isolation-trials]
  options = Selenium::WebDriver::Chrome::Options.new(args:)

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options:,
  )
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[start-maximized disable-gpu no-sandbox])

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options:,
  )
end
