module CheckAnswersHelper
  ItemStruct = Struct.new(:label, :amount_text, :name)

  def number_to_currency_or_na(number)
    number.to_d == BigDecimal("999_999_999_999.0", 12) ? "N/a" : gds_number_to_currency(number)
  end

  def nino_with_spaces(national_insurance_number)
    return nil if national_insurance_number.blank?

    national_insurance_number.scan(/.{1,2}/).join(" ")
  end

  def safe_yes_or_no(value)
    return value unless boolean?(value)

    value == true ? "Yes" : "No"
  end

  def boolean?(value)
    value.is_a?(TrueClass) || value.is_a?(FalseClass)
  end

  def build_item_struct(label, text)
    ItemStruct.new(label, text, nil)
  end
end
