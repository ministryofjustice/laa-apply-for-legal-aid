# These matchers are used for testing the contents of an XML attribute
# block in the payload.
#
# 'actual' is expected to be an instance of Nokogiri::XML::NodeSet, which
# is obtained by calling #xpath on an instance of Nokogiri::XML::Document,
# or more simply, by calling XmlExtractor on an XML string
#

module XMLBlockMatchers
  RSpec::Matchers.define :be_user_defined do
    match do |actual|
      actual.css("UserDefinedInd").text == "true"
    end

    failure_message do
      "Expected UserDefinedInd to be true:\n#{actual}\n\n"
    end
  end

  RSpec::Matchers.define :not_be_user_defined do
    match do |actual|
      actual.css("UserDefinedInd").text == "false"
    end

    failure_message do
      "Expected UserDefinedInd to be false:\n#{actual}\n\n"
    end
  end

  RSpec::Matchers.define :have_text_response do |expected|
    result = nil
    match do |actual|
      result = if expected.is_a?(Array)
                 validate_multiple_expectations(actual, expected, "text")
               else
                 validate_expectation(actual, expected, "text")
               end
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_boolean_response do |expected|
    result = nil
    match do |actual|
      result = if expected.is_a?(Array)
                 validate_multiple_expectations(actual, expected.map(&:to_s), "boolean")
               else
                 validate_expectation(actual, expected.to_s, "boolean")
               end
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_date_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected, "date")
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_number_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected.to_s, "number")
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_currency_response do |expected|
    result = nil
    match do |actual|
      result = validate_expectation(actual, expected.to_s, "currency")
      result == :ok
    end

    failure_message do
      "#{result}\n\n#{actual}"
    end
  end

  RSpec::Matchers.define :have_xml_attributes do |expected|
    actual_hash = {}

    match do |actual|
      return "A hash must be passed to this matcher, not a \"#{expected.class}\"" unless expected.is_a?(Hash)

      actual_hash = actual.each_with_object({}) do |node, memo|
        memo[node.search("Attribute").text.to_sym] = node.search("ResponseValue").text
      end

      actual_hash >= expected
    end

    failure_message do
      SuperDiff::Basic::Differs::Hash.call(expected, actual_hash, indent_level: 0)
    end

    failure_message_when_negated do
      SuperDiff::Basic::Differs::Hash.call(expected, actual_hash, indent_level: 0)
    end
  end

  def validate_expectation(actual, expected_value, expected_response_type)
    return "Block not found" if actual.blank?

    formatted_expected_value = if formatted_decimal?(expected_value, expected_response_type)
                                 sprintf("%<val>12.2f", val: expected_value).squish
                               else
                                 expected_value
                               end

    actual_response_type = actual.css("ResponseType").text
    return "Expected response type '#{expected_response_type}', got '#{actual_response_type}'" unless actual_response_type == expected_response_type

    actual_value = actual.css("ResponseValue").text
    return "Expected value '#{formatted_expected_value}', got '#{actual_value}'" unless actual_value.squish == formatted_expected_value

    :ok
  end

  def validate_multiple_expectations(actual, expected_values, expected_response_type)
    return "Block not found" if actual.blank?

    formatted_expected_values = expected_values.map do |expected_value|
      if formatted_decimal?(expected_value, expected_response_type)
        sprintf("%<val>12.2f", val: expected_value).squish
      else
        expected_value
      end
    end

    actual_response_types = actual.search("ResponseType").map(&:text)
    return "Expected all response types to be '#{expected_response_type}', got '#{actual_response_types}'" unless actual_response_types.all?(expected_response_type)

    actual_values = actual.search("ResponseValue").map(&:text)
    return "Expected value '#{formatted_expected_values}', got '#{actual_values}'" unless compare_array(actual_values, formatted_expected_values)

    :ok
  end

  def formatted_decimal?(expected_value, expected_response_type)
    return true if expected_response_type == "currency"

    return false unless expected_response_type == "numeric"

    return false if expected_value.is_a?(Integer)

    true
  end

  def compare_array(array_one, array_two)
    ((array_one - array_two) + (array_two - array_one)).blank?
  end
end
