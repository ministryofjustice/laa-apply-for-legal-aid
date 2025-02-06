module CapitalHelper
  CapitalAmountItem = Struct.new(:label, :name, :amount, :type, :amount_text)

  def capital_amounts_list(legal_aid_application)
    return nil if legal_aid_application.savings_amount.nil?

    amounts_list = legal_aid_application.savings_amount.amount_attributes&.reject! { |a| a.end_with?("accounts") }&.compact

    amounts_list.presence
  end

  def capital_assets_list(legal_aid_application)
    return nil if legal_aid_application.other_assets_declaration.nil?

    assets_list = legal_aid_application.other_assets_declaration.amount_attributes.compact

    assets_list.presence
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
end
