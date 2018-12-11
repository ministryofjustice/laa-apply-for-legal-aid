module GovukElementsFormBuilder
  # TODO: Refactor this class and remove the rubocop:disable
  class FormBuilder < ActionView::Helpers::FormBuilder # rubocop:disable Metrics/ClassLength
    # Prevents surrounding of erroneous inputs with <div class="field_with_errors">
    # https://guides.rubyonrails.org/configuring.html#configuring-action-view
    ActionView::Base.field_error_proc = proc { |html_tag| html_tag.html_safe }

    CUSTOM_OPTIONS = %i[label input_prefix field_with_error hide_hint? title inline].freeze

    delegate :content_tag, to: :@template
    delegate :errors, to: :@object

    # Usage:
    # <%= form.govuk_text_field :name %>
    #
    # A hint will be displayed if it is defined in the locale file:
    # 'helpers.hint.user.name'
    #
    # Use the :input_prefix to insert a character inside and at the beginning of the input field.
    # e.g., <%= form.govuk_text_field :property_value, input_prefix: '$' %>
    #
    # Use :field_with_error to have the input be marked as erroneous when an other attribute has an error.
    # e.g., <%= form.govuk_text_field :address_line_two, field_with_error: :address_line_one %>
    #
    # Use the hide_hint? option to not display the hint message.
    # e.g., <%= form.govuk_text_field :name, hide_hint?: true %>
    #
    def govuk_text_field(attribute, options = {})
      options[:class] = text_field_classes(attribute, options)
      input_text_form_group(attribute, options) do
        input_prefix = options[:input_prefix]
        tag_options = options.except(*CUSTOM_OPTIONS)
        tag_options[:id] = attribute
        tag_options[:'aria-describedby'] = aria_describedby(attribute, options)
        tag = text_field(attribute, tag_options)

        input_prefix ? input_prefix_group(input_prefix) { tag } : tag
      end
    end

    # Usage:
    # <%= form.govuk_radio_button(:gender, 'm')
    # <%= form.govuk_radio_button(:gender, 'm', label: 'Male')
    #
    # If label is not specified, it will be grabbed from the locale file at:
    # 'helpers.label.user.gender.f'
    #
    def govuk_radio_button(attribute, value, *args)
      options = args.extract_options!.symbolize_keys!

      radio_classes = [options[:class]]
      options[:class] = radio_classes.unshift('govuk-radios__input').compact.join(' ')
      radio_html = radio_button(attribute, value, options.except(*CUSTOM_OPTIONS))

      label_options = { value: value.to_s, class: 'govuk-label govuk-radios__label' }
      label_html = label(attribute, options[:label], label_options)

      content_tag(:div, class: 'govuk-radios__item') do
        concat_tags(radio_html, label_html)
      end
    end

    # Usage:
    # Labels of each radio buttons can be either passed as parameters or defined in the locale file.
    # For examples, for the gender of a user, if the radio button values are 'm' and 'f' the labels can be define at:
    # 'helpers.label.user.gender.f'
    #
    # Option 1:
    # <%= form.govuk_collection_radio_buttons(:gender, ['f', 'm']) %>
    # Option 2:
    # <%= form.govuk_collection_radio_buttons(:gender, [{ code: 'f' }, { code: 'm' }], :code) %>
    # Option 3:
    # <%= form.govuk_collection_radio_buttons(:gender, [{ code: 'f', label: 'Female' }, { code: 'm', label: 'Male' }], :code, :label) %>
    #
    # A hint will be displayed if it is defined in the locale file:
    # 'helpers.hint.user.gender'
    #
    # You can pass a title with the :title parameter.
    # e.g., <%= form.govuk_collection_radio_buttons(:gender, ['f', 'm'], title: 'What is your gender?') %>
    #
    # Use the :inline parameter to have the radio buttons displayed horizontally rather than vertically
    # e.g., <%= form.govuk_collection_radio_buttons(:gender, ['f', 'm'], inline: true) %>
    #
    # TODO: Refactor this method and remove the rubocop:disable
    def govuk_collection_radio_buttons(attribute, collection, *args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      options = args.extract_options!.symbolize_keys!
      value_attr, label_attr = extract_value_and_label_attributes(args)

      content_tag(:div, class: collection_radio_buttons_classes(attribute, options)) do
        fieldset(attribute, options) do
          classes = ['govuk-radios']
          classes << 'govuk-radios--inline' if options[:inline]
          concat_tags(
            hint_and_error_tags(attribute, options),
            content_tag(:div, class: classes.join(' ')) do
              inputs = collection.map do |obj|
                value = value_attr ? obj[value_attr] : obj
                label = label_attr ? obj[label_attr] : nil
                govuk_radio_button(attribute, value, options.merge(label: label))
              end
              concat_tags(inputs)
            end
          )
        end
      end
    end

    private

    def concat_tags(*tags)
      tags.compact.join('').html_safe
    end

    def extract_value_and_label_attributes(args)
      value_attr = args[0].is_a?(Hash) ? nil : args[0]
      label_attr = args[1].is_a?(Hash) ? nil : args[1]
      [value_attr, label_attr]
    end

    def collection_radio_buttons_classes(attribute, options)
      classes = ['govuk-form-group']
      classes << 'govuk-form-group--error' if error?(attribute, options)
      classes.join(' ')
    end

    def text_field_classes(attribute, options)
      classes = [options[:class]]
      classes << 'govuk-input'
      classes << 'govuk-input--error' if error?(attribute, options)
      classes << 'govuk-prefix-input__inner__input' if options[:input_prefix]
      classes.compact.join(' ')
    end

    def input_prefix_group(input_prefix)
      content_tag :div, class: 'govuk-prefix-input' do
        content_tag :div, class: 'govuk-prefix-input__inner' do
          prefix = content_tag :span, input_prefix, class: 'govuk-prefix-input__inner__unit'
          concat_tags(prefix, yield)
        end
      end
    end

    def input_text_form_group(attribute, options)
      classes = ['govuk-form-group']
      classes << 'govuk-form-group--error' if error?(attribute, options)
      content_tag :div, class: classes.join(' ') do
        label = label(attribute, class: 'govuk-label', for: attribute)
        concat_tags(label, hint_and_error_tags(attribute, options), yield)
      end
    end

    def fieldset(attribute, options)
      content_tag(:fieldset, class: 'govuk-fieldset', 'aria-describedby': aria_describedby(attribute, options)) do
        legend_tag = options[:title] ? fieldset_legend(options[:title]) : nil
        concat_tags(legend_tag, yield)
      end
    end

    def aria_describedby(attribute, options)
      aria_describedby = []
      aria_describedby << "#{attribute}-hint" if hint?(attribute, options)
      aria_describedby << "#{attribute}-error" if error?(attribute, options)
      aria_describedby.join(' ')
    end

    def fieldset_legend(title)
      content_tag(:legend, class: 'govuk-fieldset__legend govuk-fieldset__legend--xl') do
        content_tag(:h1, title, class: 'govuk-fieldset__heading')
      end
    end

    def hint_and_error_tags(attribute, options)
      concat_tags(hint_tag(attribute, options), error_tag(attribute, options))
    end

    def hint?(attribute, options)
      !options[:hide_hint?] && hint_message(attribute)
    end

    def hint_message(attribute)
      I18n.translate("helpers.hint.#{@object_name}.#{attribute}", default: nil)
    end

    def hint_tag(attribute, options)
      return unless hint?(attribute, options)

      content_tag(:span, hint_message(attribute), class: 'govuk-hint', id: "#{attribute}-hint")
    end

    def error_tag(attribute, options)
      return unless error?(attribute, options)

      message = object.errors[attribute].join(', ')
      return unless message.present?

      content_tag(:span, message, class: 'govuk-error-message', id: "#{attribute}-error")
    end

    def error?(attribute, options)
      attr = options[:field_with_error] || attribute
      object.respond_to?(:errors) &&
        errors.messages.key?(attr) &&
        errors.messages[attr].present?
    end
  end
end
