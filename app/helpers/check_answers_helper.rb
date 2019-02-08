module CheckAnswersHelper
  def check_answer_link(url:, question:, answer:, name:)
    render(
      'shared/check_answers/item',
      name: name,
      url: url,
      question: question,
      answer: answer
    )
  end

  def check_answer_list(url:, question:, answers:, name:)
    render(
      'shared/check_answers/items',
      name: name,
      url: url,
      question: question,
      answers: answers
    )
  end

  def check_answer_currency_list(url:, question:, answer_hash:, name:)
    render(
      'shared/check_answers/currency_items',
      name: name,
      url: url,
      question: question,
      answer_hash: answer_hash
    )
  end
end
