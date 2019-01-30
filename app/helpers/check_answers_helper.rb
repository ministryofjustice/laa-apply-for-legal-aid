module CheckAnswersHelper
  def check_answer_link(url:, question:, answer:, name:, is_long: nil)
    partial = case answer
              when Hash
                'currency_items'
              when Array
                'items'
              else
                'item'
              end
    is_long = '--long' if is_long
    render(
      partial: "shared/check_answers/#{partial}",
      locals: { url: url, question: question, answer: answer, name: name, is_long: is_long }
    )
  end
end
