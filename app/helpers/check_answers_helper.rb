module CheckAnswersHelper
  ItemStruct = Struct.new(:label, :amount_text, :name)
  # Creates one dictionary list item - so needs to be used within a `govuk-summary-list` `dl`:
  #     <dl class="govuk-summary-list govuk-!-margin-bottom-9">
  #       <%= check_answer_link ..... %>
  #     </dl>
  def check_answer_link(question:, answer:, name:, url: nil, read_only: false, no_border: false)
    render(
      "shared/check_answers/item",
      name:,
      url:,
      question:,
      answer:,
      read_only: url.nil? ? true : read_only,
      no_border:,
    )
  end

  def check_answer_no_link(question:, answer:, name:, no_border: false, read_only: false)
    render(
      "shared/check_answers/no_link_item",
      name:,
      question:,
      answer:,
      read_only:,
      no_border:,
    )
  end

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

  def check_long_question_no_link(question:, answer:, name:, no_border: false)
    render(
      "shared/check_answers/no_link_long_item",
      name:,
      question:,
      answer:,
      no_border:,
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
