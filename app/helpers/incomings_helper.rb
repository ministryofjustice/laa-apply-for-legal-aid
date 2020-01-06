module IncomingsHelper
  def incomings_list(incomings, locale_namespace:)
    items = TransactionType.credits&.map do |income_type|
      OpenStruct.new(
        label: t("#{locale_namespace}.#{income_type.name}"),
        name: income_type.name,
        amount_text: yes_no(@legal_aid_application.transaction_types.credits.pluck(:name).include?(income_type.name))
      )
    end

    return nil unless items.present?

    {
      items: items
    }
  end
end
