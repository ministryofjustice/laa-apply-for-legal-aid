module UserTransactionsHelper
  TransactionItemStruct = Struct.new(:label, :name, :amount_text)

  def incomings_list(incomings, locale_namespace:)
    items = TransactionType.credits&.map do |income_type|
      next if income_type.disregarded_benefit?

      TransactionItemStruct.new(t("#{locale_namespace}.#{income_type.name}"),
                                income_type.name,
                                yes_no(incomings.pluck(:name).include?(income_type.name)))
    end

    return nil if items.blank?

    {
      items: items.compact,
    }
  end

  def payments_list(payments, locale_namespace:)
    items = TransactionType.debits&.map do |payment_type|
      TransactionItemStruct.new(
        t("#{locale_namespace}.#{payment_type.name}"),
        payment_type.name,
        yes_no(payments.pluck(:name).include?(payment_type.name)),
      )
    end

    return nil if items.blank?

    {
      items:,
    }
  end
end
