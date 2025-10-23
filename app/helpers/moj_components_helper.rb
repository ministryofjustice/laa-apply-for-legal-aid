module MojComponentsHelper
  def interruption_card(heading:, actions: nil, &body)
    body = capture(&body) if body

    render("shared/moj_components_templates/interruption_card_template", heading:, body:, actions:)
  end
end
