class CurrencyCleaner
  THOUSANDS_SEPARATOR_REGEX = /,(?=\d{3}\b)/.freeze
  LEADING_POUND_SIGN_REGEX = /^£/.freeze
  PURE_NUMERIC_REGEX = /^-?\d+\.?\d+?$/.freeze

  def initialize(value)
    @original_value = value
  end

  # will remove all commas if valid i.e. followed by 3 digits
  # if invalid, the original String is returned
  def call
    clean_value = remove_commas
    PURE_NUMERIC_REGEX.match?(clean_value) ? clean_value : @original_value
  end

  private

  def remove_commas
    @original_value.sub(LEADING_POUND_SIGN_REGEX, '').gsub(THOUSANDS_SEPARATOR_REGEX, '')
  end
end
