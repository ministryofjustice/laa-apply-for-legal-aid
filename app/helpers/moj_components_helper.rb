module MojComponentsHelper
  def interruption_card(heading:, actions: nil, &body)
    body = capture(&body) if body

    render("shared/moj_components_templates/interruption_card_template", heading:, body:, actions:)
  end

  def information_alert(heading:, body:, dismiss_href:)
    render("shared/moj_components_templates/information_alert", heading:, body:, dismiss_href:)
  end
end
