module CheckAnswersHelper
  ItemStruct = Struct.new(:label, :amount_text, :name)

  # Creates both the outer `div` and the inner list items
  def check_answer_change_link(name:, url:, question:, read_only: false)
    render(
      "shared/check_answers/only_link_section",
      name:,
      url:,
      question:,
      read_only:,
    )
  end

  def number_to_currency_or_na(number)
    number.to_d == BigDecimal("999_999_999_999.0", 12) ? "N/a" : gds_number_to_currency(number)
  end

  def safe_yes_or_no(value)
    return value unless boolean?(value)

    value == true ? "Yes" : "No"
  end

  def boolean?(value)
    value.is_a?(TrueClass) || value.is_a?(FalseClass)
  end

  def build_ostruct(label, text)
    ItemStruct.new(label, text, nil)
  end
end
