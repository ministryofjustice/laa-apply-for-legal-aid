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

  def change_address_link(applicant, options = {})
    options[:anchor] = :postcode
    return providers_legal_aid_application_address_lookup_path(options) if applicant.address&.lookup_used?

    providers_legal_aid_application_address_path(options)
  end
end
