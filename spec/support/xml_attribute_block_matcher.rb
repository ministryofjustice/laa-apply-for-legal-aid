# These matchers are used for testing the contents of an XML attribute
# block in the payload.
#
# 'actual' is expected to be an instance of Nokogiri::XML::NodeSet, which
# is obtained by calling #xpath on an instance of Nokogiri::XML::Document,
# or more simply, by calling XmlExtractor on an XML string
#
RSpec::Matchers.define :have_response_type do |expected|
  match do |actual|
    actual_response_type = actual.css('ResponseType').text
    actual_response_type == expected
  end
  failure_message do |actual|
    actual_response_type = actual.css('ResponseType').text
    "Expected ResponseType to be #{expected}, was #{actual_response_type}\n#{actual}"
  end
end

RSpec::Matchers.define :have_response_value do |expected|
  match do |actual|
    actual_response_value = actual.css('ResponseValue').text
    # response_value = actual.css('ResponseValue').text
    # actual_response_value = response_value.delete!("\n")
    actual_response_value == expected
  end
  failure_message do |actual|
    actual_response_value = actual.css('ResponseValue').text
    "Expected ResponseValue to be #{expected}, was #{actual_response_value}\n#{actual}"
  end
end
