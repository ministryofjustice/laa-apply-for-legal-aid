module GovUkFormHelper
  def govuk_form_group(&block)
    content = capture(&block)
    render 'shared/forms/form_group', content: content
  end

  def govuk_fieldset_header(text, padding_below: nil)
    padding_class = padding_below && "govuk-!-padding-bottom-#{padding_below}"
    render(
      'shared/forms/fieldset_header',
      text: text,
      padding_class: padding_class
    )
  end

  def govuk_radio_inputs(field_name, value_label_pairs)
    render(
      'shared/forms/radio_inputs',
      field_name: field_name,
      value_label_pairs: value_label_pairs
    )
  end

  def govuk_hint(text)
    content_tag :span, text, class: 'govuk-hint'
  end

  def govuk_submit_button(text)
    submit_tag text, class: 'govuk-button'
  end
end
