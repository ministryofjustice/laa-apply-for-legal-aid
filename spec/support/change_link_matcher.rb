RSpec::Matchers.define :have_change_link do |field_name, expected_link|
  match do |actual|
    link = extract_link(actual, field_name)
    link == expected_link
  end
  failure_message do |actual|
    link = extract_link(actual, field_name)
    if link.nil?
      "Expected to find change link for #{field_name}, but none found"
    else
      "Expected change link for #{field_name} to be #{expected_link}, was #{link}"
    end
  end

  def extract_link(html, field_name)
    document = Nokogiri::HTML.parse(html)
    links = document.css("div#app-check-your-answers__#{field_name} .app-check-your-answers__change a")
    links.first&.attr('href')
  end
end
