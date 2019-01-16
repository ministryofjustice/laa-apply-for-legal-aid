module CheckAnswersHelper
  def check_answer_link(url:, question:, answer:, name:)
    partial = case answer
              when Hash
                'currency_items'
              when Array
                'items'
              else
                'item'
              end
    render(
      partial: "shared/check_answers/#{partial}",
      locals: { url: url, question: question, answer: answer, name: name }
    )
  end
end
