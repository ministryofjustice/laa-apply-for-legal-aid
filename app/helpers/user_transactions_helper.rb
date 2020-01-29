module UserTransactionsHelper
  def incomings_list(incomings, locale_namespace:)
    items = TransactionType.credits&.map do |income_type|
      OpenStruct.new(
        label: t("#{locale_namespace}.#{income_type.name}"),
        name: income_type.name,
        amount_text: yes_no(incomings.pluck(:name).include?(income_type.name))
      )
    end

    return nil unless items.present?

    {
      items: items
    }
  end

  def payments_list(payments, locale_namespace:)
    items = TransactionType.debits&.map do |payment_type|
      OpenStruct.new(
        label: t("#{locale_namespace}.#{payment_type.name}"),
        name: payment_type.name,
        amount_text: yes_no(payments.pluck(:name).include?(payment_type.name))
      )
    end

    return nil unless items.present?

    {
      items: items
    }
  end
end
