def spectre_client
  @spectre_client ||= begin
    app_name = Rails.application.engine_name
    current_branch = `git symbolic-ref --short HEAD`.chomp
    spectre_url = 'http://localhost:3100'
    SpectreClient::Client.new(app_name, current_branch, spectre_url)
  end
end

Then("I take a snapshot of {string}") do |name|
  page.save_screenshot('image.png')
  file_path = Rails.root.join('tmp/capybara/image.png')
  spectre_client.submit_test({
    name: name,
    size: '100',
    browser: 'selenium',
    screenshot: File.new(file_path, 'rb'),
    source_url: 'http://localhost:3000/'
  })
end
