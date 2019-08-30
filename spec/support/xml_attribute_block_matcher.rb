# These matchers are used for testing the contents of an XML attribute
# block in the payload.
#
# 'actual' is expected to be an instance of Nokogiri::XML::NodeSet, which
# is obtained by calling #xpath on an instance of Nokogiri::XML::Document,
# or more simply, by calling XmlExtractor on an XML string
#

module XMLBlockMatchers
  RSpec::Matchers.define :have_text_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected, 'text')
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_boolean_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected.to_s, 'boolean')
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_date_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected, 'date')
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_number_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected.to_s, 'number')
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_currency_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected.to_s, 'currency')
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  def validate_expectation(actual, expected_value, expected_response_type)
    return 'Block not found' if actual.blank?

    actual_response_type = actual.css('ResponseType').text
    return "Expected response type '#{expected_response_type}', got '#{actual_response_type}'" unless actual_response_type == expected_response_type

    actual_value = actual.css('ResponseValue').text
    return "Expected value '#{expected_value}', got '#{actual_value}'" unless actual_value.squish == expected_value.squish

    :ok
  end
end
