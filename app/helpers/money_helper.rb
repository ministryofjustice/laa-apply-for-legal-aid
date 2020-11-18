module MoneyHelper
  def value_with_currency_unit(value, currency)
    number_to_currency(value, unit: I18n.t("currency.#{currency.downcase}", default: currency))
  end

  def number_to_currency_or_original_string(value)
    value.is_a?(String) ? value : gds_number_to_currency(value, unit: '')
  end

  def gds_number_to_currency(value, opts = {})
    return value unless value.is_a?(Numeric)

    opts[:precision] = 0 if (value - value.to_i).zero?

    number_to_currency(value, opts)
  end
end
