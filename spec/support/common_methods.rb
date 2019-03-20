def parsed_response_body(html = response.body)
  Nokogiri::HTML(html)
end

def button_value(html_body:, attr:)
  parsed_response_body(html_body).css(attr)[0].attr('value')
end
