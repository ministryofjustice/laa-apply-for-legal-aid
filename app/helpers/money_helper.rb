module MoneyHelper
  def value_with_currency_unit(value, currency)
    number_to_currency(value, unit: I18n.t("currency.#{currency.downcase}", default: currency))
  end

  def number_to_currency_or_original_string(value)
    value.is_a?(String) ? value : gds_number_to_currency(value, unit: '')
  end

  def gds_number_to_currency(value, opts = {})
    return value unless number?(value)

    currency = value.to_d

    opts[:precision] = 0 if (currency - currency.to_i).zero?

    number_to_currency(currency, opts)
  end

  def number?(string)
    Float(string)
  rescue StandardError
    false
  end

  def valid_amount?(amount)
    amount.to_i >= 0
  end
end
