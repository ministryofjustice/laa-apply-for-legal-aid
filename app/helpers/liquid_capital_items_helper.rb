module LiquidCapitalItemsHelper
  def capital_items_to_display?(legal_aid_application, item)
    return false if legal_aid_application.passported? && ['Online current accounts', 'Online savings accounts'].include?(item[:description])

    true
  end

  def item_description(legal_aid_application, item)
    return 'Savings accounts your client cannot access online' if item[:description].eql?('Savings accounts') && legal_aid_application.non_passported?

    item[:description]
  end
end
