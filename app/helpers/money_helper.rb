module MoneyHelper
  def value_with_currency_unit(value, currency)
    number_to_currency(value, unit: I18n.t("currency.#{currency.downcase}", default: currency))
  end
end
