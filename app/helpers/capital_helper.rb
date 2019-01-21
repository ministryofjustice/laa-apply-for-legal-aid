module CapitalHelper
  def capital_amounts_list(capital, locale_namespace:)
    items = capital&.amount_attributes&.map do |attribute, amount|
      next unless amount

      label = t("#{locale_namespace}#{attribute}")
      [label, amount]
    end
    items&.compact!

    return nil unless items.present?

    {
      items: items,
      total_value: items.map(&:last).sum
    }
  end
end
