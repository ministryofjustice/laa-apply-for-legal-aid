module CapitalHelper
  def capital_amounts_list(capital, locale_namespace:, percentage_values: [])
    items = capital_amount_items(capital, locale_namespace, percentage_values)
    items&.compact!
    return nil unless items.present?

    {
      items: items,
      total_value: items.map(&:amount).sum
    }
  end

  def capital_amount_items(capital, locale_namespace, percentage_values)
    capital&.amount_attributes&.reject { |c| c == 'offline_savings_accounts' }&.map do |attribute, amount|
      next unless amount

      type = percentage_values.include?(attribute.to_sym) ? :percentage : :currency

      OpenStruct.new(
        label: t("#{locale_namespace}#{attribute}"),
        amount: amount,
        type: type,
        amount_text: capital_amount_text(amount, type)
      )
    end
  end

  def capital_amount_text(amount, type)
    if type == :percentage
      number_to_percentage(amount, precision: 2)
    else
      number_to_currency(amount)
    end
  end
end
