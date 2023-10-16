module CapitalHelper
  CapitalAmountItem = Struct.new(:label, :name, :amount, :type, :amount_text)

  def capital_amounts_list(legal_aid_application, locale_namespace:, percentage_values: [])
    attributes = capital_amount_attributes(legal_aid_application.other_assets_declaration, legal_aid_application)
    attributes = combine_second_home_attributes(attributes)
    build_asset_list(attributes, locale_namespace, percentage_values)
  end

  def capital_accounts_list(legal_aid_application, locale_namespace:, percentage_values: [])
    attributes = capital_amount_attributes(legal_aid_application.savings_amount, legal_aid_application)&.reject! { |a| !a.end_with?("accounts") }
    build_asset_list(attributes, locale_namespace, percentage_values)
  end

  def capital_assets_list(legal_aid_application, locale_namespace:, percentage_values: [])
    attributes = capital_amount_attributes(legal_aid_application.savings_amount, legal_aid_application)&.reject! { |a| a.end_with?("accounts") }
    build_asset_list(attributes, locale_namespace, percentage_values)
  end

  def build_asset_list(attributes, locale_namespace, percentage_values)
    items = capital_amount_items(attributes, locale_namespace, percentage_values)
    items&.compact!
    return nil if items.blank?

    {
      items:,
    }
  end

  def combine_second_home_attributes(items)
    return nil if items.blank?

    second_home_attributes = items.select { |attr_name, _| attr_name.include?("second_home") }
    if second_home_attributes.all? { |_, value| value.nil? }
      items.except!(*second_home_attributes.keys)
      items[:second_home] = nil
    end
    items
  end

  def capital_amount_items(items, locale_namespace, percentage_values)
    items&.map do |attribute, amount|
      type = percentage_values.include?(attribute.to_sym) ? :percentage : :currency
      CapitalAmountItem.new(
        t("#{locale_namespace}#{attribute}"),
        attribute.to_s.delete_prefix("check_box_"),
        amount,
        type,
        capital_amount_text(amount, type),
      )
    end
  end

  def capital_amount_text(amount, type)
    if amount.nil?
      t("generic.no")
    elsif type == :percentage
      number_to_percentage(amount, precision: 2)
    else
      gds_number_to_currency(amount)
    end
  end

  def capital_amount_attributes(capital, legal_aid_application)
    return capital&.amount_attributes if legal_aid_application.passported? || legal_aid_application.uploading_bank_statements?

    capital&.amount_attributes&.reject { |c| c == "offline_savings_accounts" }
  end
end
