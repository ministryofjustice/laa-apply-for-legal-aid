def parsed_response_body(html = response.body)
  Nokogiri::HTML(html)
end

def button_value(html_body:, attr:)
  parsed_response_body(html_body).css(attr)[0].attr(:value)
end

def save_xml_in_temp_file(_xml)
  filename = Rails.root.join("tmp/generated_add_case_request.xml")
  File.open(filename, "w") do |fp|
    fp.puts "<!-- generated by rspec #{Time.current} -->"
    fp.puts requestor.formatted_xml
  end
  Rails.logger.info "XML saved in #{filename}"
end
