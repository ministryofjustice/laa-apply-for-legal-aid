module MoneyHelper
  def value_with_currency_unit(value, currency)
    number_to_currency(value, unit: I18n.t("currency.#{currency.downcase}", default: currency))
  end

  def number_to_currency_or_original_string(value)
    value.is_a?(String) ? value : number_to_currency(value, unit: '')
  end
end
