module GovUkFormHelper
  # Creates a template variable for yes/no options for radio buttons in a form

  def yes_no_options
    [OpenStruct.new(value: true, label: I18n.t('generic.yes')),
     OpenStruct.new(value: false, label: I18n.t('generic.no'))]
  end

  # Either passing in the heading text and let this method sort out its formatting,
  # or define the heading content manually by wrapping this method around a formated header.
  # So:
  #   <%= govuk_fieldset_header 'My Heading' %>
  #
  # or
  #
  #   <%= govuk_fieldset_header do %>
  #     <h1 class="govuk-fieldset__heading">My Heading</h1>
  #   <% end %>
  #
  # Both result in the same output

  def govuk_fieldset_header(text = nil, size: 'xl', padding_below: nil, &block)
    heading = text ? content_tag(:h1, text, class: 'govuk-fieldset__heading') : capture(&block)
    padding_class = padding_below && "govuk-!-padding-bottom-#{padding_below}"
    render(
      'shared/forms/fieldset_header',
      heading: heading,
      size: size,
      padding_class: padding_class
    )
  end

  def govuk_error_message(text, args = {})
    return if text.blank?

    content_tag :span, text, merge_with_class(args, 'govuk-error-message')
  end

  # Adds or appends `class_text` to `args[:class]`. So:
  #   args = { id: 'thing' }
  #   merge_with_class(args, 'bar') => { class: 'bar', id: 'thing' }
  #
  #   args = { class: 'foo', id: 'thing' }
  #   merge_with_class(args, 'bar') => { class: 'foo bar', id: thing }
  def merge_with_class(args, class_text)
    class_text = [class_text, args[:class]]
    class_text.compact!
    args.merge(class: class_text.join(' '))
  end

  def merge_with_class!(args, class_text)
    class_text = [class_text, args[:class]]
    class_text.compact!
    class_text.flatten!
    args.merge!(class: class_text.join(' '))
  end
end
