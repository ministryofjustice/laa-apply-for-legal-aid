def parsed_response_body(html = response.body)
  Nokogiri::HTML(html)
end
