module CheckProviderAnswersHelper
  def check_provider_answer_link(url:, question:, answer:, name:)
    render(
      partial: 'check_provider_answers_item',
      locals: {
        url: url,
        question: question,
        answer: answer,
        name: name
      }
    )
  end
end
