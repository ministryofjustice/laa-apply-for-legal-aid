RSpec::Matchers.define :have_back_link do |expected|
  match do |actual|
    back_link = extract_back_link(actual)
    back_link == expected
  end
  failure_message do |actual|
    back_link = extract_back_link(actual)
    if back_link.nil?
      'Expected to find back link, but none found'
    else
      "Expected back link to be #{expected}, was #{back_link}"
    end
  end

  def extract_back_link(html)
    document = Nokogiri::HTML.parse(html)
    atag = document.css('a.govuk-back-link').first
    atag.nil? ? nil : atag.attr('href')
  end
end
