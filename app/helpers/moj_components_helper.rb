module MojComponentsHelper
  def interruption_card(heading:, actions: nil, &body)
    body = capture(&body) if body

    render("shared/moj_components_templates/interruption_card_template", heading:, body:, actions:)
  end

  def date_picker_field(form, attribute_name, **kwargs)
    render("shared/moj_components_templates/forms/date_picker_field", form:, attribute_name:, kwargs:)
  end
end
