module CapitalHelper
  def capital_amounts_list(capital, locale_namespace:)
    return [] unless capital

    capital.amount_attributes.map { |attribute, amount|
      next unless amount

      label = t("#{locale_namespace}#{attribute}")
      amount = number_to_currency(amount, unit: t('currency.gbp'))
      "#{label} #{amount}"
    }.compact
  end
end
