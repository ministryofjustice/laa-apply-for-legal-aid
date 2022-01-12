RSpec::Matchers.define :have_back_link do |expected|
  match do |actual|
    back_link = extract_back_link(actual)
    matching_urls?(back_link, expected)
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
    atag = parsed_response_body(html).css('a.govuk-back-link').first
    atag.nil? ? nil : atag.attr('href')
  end

  # URLs match if content same even if order of query part is diferent
  def matching_urls?(url1, url2)
    uri1 = URI(url1)
    uri2 = URI(url2)
    uri1.scheme == uri2.scheme &&
      uri1.host == uri2.host &&
      uri1.path == uri2.path &&
      queries_match?(uri1, uri2) &&
      uri1.fragment == uri2.fragment
  end

  def queries_match?(uri1, uri2)
    hash1 = CGI.parse(uri1.query)
    hash2 = CGI.parse(uri2.query)
    hash1.sort == hash2.sort
  end
end
