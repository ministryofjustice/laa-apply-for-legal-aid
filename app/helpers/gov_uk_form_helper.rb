module GovUkFormHelper
  RadioOption = Struct.new(:value, :label, :radio_hint)

  # Creates a template variable for yes/no options for radio buttons on a form for use with govuk_collection_radio_buttons method.
  #
  # include hash for radio button hints if required, e.g.
  #
  # yes_no_options                                               - will print no hints under individual radio buttons
  # yes_no_options(yes: 'this means Go!', no: 'This means Stop') - will print hints under both radios
  # yes_no_options(yes: 'This means Go!')                        - will print hint under yes radio only
  #
  def yes_no_options(radio_hints = {})
    [
      RadioOption.new(true, I18n.t("generic.yes"), radio_hints[:yes]),
      RadioOption.new(false, I18n.t("generic.no"), radio_hints[:no]),
    ]
  end

  def govuk_error_message(text, args = {})
    return if text.blank?

    content_tag :span, text, merge_with_class(args, "govuk-error-message")
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
    args.merge(class: class_text.join(" "))
  end
end
