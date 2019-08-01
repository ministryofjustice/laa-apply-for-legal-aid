module CheckAnswersHelper
  # Creates one dictionary list item - so needs to be used within a `govuk-summary-list` `dl`:
  #     <dl class="govuk-summary-list govuk-!-margin-bottom-9">
  #       <%= check_answer_link ..... %>
  #     </dl>
  def check_answer_link(url:, question:, answer:, name:, read_only: false, no_border: false)
    render(
      'shared/check_answers/item',
      name: name,
      url: url,
      question: question,
      answer: answer,
      read_only: read_only,
      no_border: no_border
    )
  end

  def check_answer_no_link(question:, answer:, name:)
    render(
      'shared/check_answers/no_link_item',
      name: name,
      question: question,
      answer: answer
    )
  end

  def check_answer_no_link_bold(question:, answer:, name:)
    render(
      'shared/check_answers/no_link_item_bold',
      name: name,
      question: question,
      answer: answer
    )
  end

  # Creates both the outer `dl` and the inner list items
  def check_answer_one_change_link(url:, question:, answer_hash:, name:)
    render(
      'shared/check_answers/one_link_section',
      name: name,
      url: url,
      question: question,
      answer_hash: answer_hash
    )
  end

  def check_answer_change_link(name:, url:, question:)
    render(
      'shared/check_answers/only_link_section',
      name: name,
      url: url,
      question: question
    )
  end
end
