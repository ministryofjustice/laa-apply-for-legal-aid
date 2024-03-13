module ScreenshotHelper
  # selenium headless chrome solution for full screenshot
  def screenshot_and_open_image
    file_path = screenshot_image
    # Launchy.open file_path
    open_file(file_path)
  end

  def screenshot_image(name = "capybara-screenshot")
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(*dimensions)
    screenshot_name = "#{Time.current.utc.iso8601.delete('-').delete(':')}-#{name}.png"
    file_path = Rails.root.join("tmp/capybara/#{screenshot_name}").to_s
    save_screenshot(file_path)
    file_path
  end

  def dimensions
    driver = Capybara.current_session.driver
    total_width = driver.execute_script("return document.body.offsetWidth")
    total_height = driver.execute_script("return document.body.scrollHeight")
    [total_width, total_height]
  end

  def open_file(file)
    system("open #{file}") if RUBY_PLATFORM.include?("darwin")
    system("xdg-open #{file}") if RUBY_PLATFORM.include?("linux")
    system("start #{file}") if RUBY_PLATFORM.match?(/mswin|mingw|cygwin/)
    puts "Unsupported platform: #{RUBY_PLATFORM}" unless RUBY_PLATFORM.match?(/darwin|linux|mswin|mingw|cygwin/)
  end
end

World(ScreenshotHelper)
