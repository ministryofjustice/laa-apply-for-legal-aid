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

  # Not used currently, left in for now in case the future CYA changes require it
  # def check_long_questions_single_change_link(url:, question:, answer_hash:, name:, read_only: false)
  #   render(
  #     "shared/check_answers/one_change_link_long_answers_section",
  #     url:,
  #     name:,
  #     question:,
  #     answer_hash:,
  #     read_only:,
  #   )
  # end

  def check_long_question_no_link(question:, answer:, name:, no_border: false)
    render(
      "shared/check_answers/no_link_long_item",
      name:,
      question:,
      answer:,
      no_border:,
    )
  end

  def check_answer_for_cash_transactions(name:, question:, legal_aid_application:, transaction_type:)
    render(
      "shared/check_answers/no_link_cash_transaction_item",
      name:,
      question:,
      legal_aid_application:,
      transaction_type:,
    )
  end

  def check_answer_for_transaction_types(name:, question:, legal_aid_application:, transaction_type:)
    render(
      "shared/check_answers/no_link_transaction_type_item",
      name:,
      question:,
      legal_aid_application:,
      transaction_type:,
    )
  end

  def check_answer_for_regular_transactions(name:, question:, legal_aid_application:, transaction_type:)
    render(
      "shared/check_answers/regular_transaction_item",
      name:,
      question:,
      legal_aid_application:,
      transaction_type:,
    )
  end

  def number_to_currency_or_na(number)
    number.to_d == BigDecimal("999_999_999_999.0") ? "N/a" : gds_number_to_currency(number)
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
