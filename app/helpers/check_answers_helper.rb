module CheckAnswersHelper
  def check_answer_link(url:, question:, answer:, name:)
    render(
      partial: 'shared/check_answers_item',
      locals: {
        url: url,
        question: question,
        answer: answer,
        name: name
      }
    )
  end
end
