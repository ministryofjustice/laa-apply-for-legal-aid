class CurrencyValidator < ActiveModel::Validations::NumericalityValidator
  ONLY_2_DECIMALS_PATTERN = /(\A-?[0-9]+\z)|(\A-?[0-9]*\.[0-9]{,2}\z)/.freeze

  def validate_each(record, attr_name, value)
    clean_value = clean_numeric_value(value)
    super(record, attr_name, clean_value)
    return if record.errors[attr_name].any?

    record.errors.add(attr_name, :too_many_decimals) unless ONLY_2_DECIMALS_PATTERN.match?(clean_value)
  end

  def clean_numeric_value(value)
    CurrencyCleaner.new(value).call
  end
end
