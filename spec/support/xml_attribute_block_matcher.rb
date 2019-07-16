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
    actual_response_type = actual.css('ResponseValue').text
    actual_response_type == expected
  end
  failure_message do |actual|
    actual_response_type = actual.css('ResponseValue').text
    "Expected ResponseValue to be #{expected}, was #{actual_response_type}\n#{actual}"
  end
end
