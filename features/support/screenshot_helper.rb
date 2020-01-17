module ScreenshotHelper
   # selenium headless chrome solution for full screenshot
  def screenshot_and_open_image
    file_path = screenshot_image
    Launchy.open file_path
  end

  def screenshot_image(name = 'capybara-screenshot')
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(*dimensions)
    screenshot_name = "#{name}-#{Time.now.utc.iso8601.gsub('-', '').gsub(':', '')}.png"
    file_path = Rails.root.join("tmp/capybara/#{screenshot_name}").to_s
    save_screenshot(file_path)
    file_path
  end

  def dimensions
    driver = Capybara.current_session.driver
    total_width = driver.execute_script("return document.body.offsetWidth")
    total_height = driver.execute_script("return document.body.scrollHeight")
    return [total_width, total_height]
  end
end

World(ScreenshotHelper)
