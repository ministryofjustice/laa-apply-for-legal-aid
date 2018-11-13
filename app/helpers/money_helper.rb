module MoneyHelper
  def currency_symbol(currency)
    return '£' if currency == 'GBP'
    return '$' if currency == 'USD'
    return '€' if currency == 'EUR'
    currency
  end
   def display_value_with_symbol(value, currency)
    number_to_currency(value, unit: currency_symbol(currency))
  end
end
