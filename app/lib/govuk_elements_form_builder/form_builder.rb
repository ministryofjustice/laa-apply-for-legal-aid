module GovukElementsFormBuilder
  # TODO: Refactor this class and remove the rubocop:disable
  class FormBuilder < ActionView::Helpers::FormBuilder # rubocop:disable Metrics/ClassLength
    # Prevents surrounding of erroneous inputs with <div class="field_with_errors">
    # https://guides.rubyonrails.org/configuring.html#configuring-action-view
    ActionView::Base.field_error_proc = proc { |html_tag| html_tag.html_safe }

    CUSTOM_OPTIONS = %i[label input_prefix field_with_error hint title inline text_input input_attributes collection].freeze

    delegate :content_tag, to: :@template
    delegate :errors, to: :@object

    # Usage:
    # <%= form.govuk_text_field :name %>
    # <%= form.govuk_text_area :statement %>
    #
    # You can specify the label and hint copies:
    # e.g., <%= form.govuk_text_field :name, label: 'Enter your name', hint: 'Your real name' %>
    #
    # Otherwise, label and hints are to be defined in the locale file:
    # 'helpers.hint.user.name'
    # 'helpers.label.user.name'
    #
    # Use the "hint: nil" option to not display the hint message.
    # e.g., <%= form.govuk_text_field :name, hint: nil %>
    #
    # Use the "label: nil" option to not display a label.
    # e.g., <%= form.govuk_text_field :name, label: nil, hint: 'hint text' %>
    #
    # Use the :input_prefix to insert a character inside and at the beginning of the input field.
    # e.g., <%= form.govuk_text_field :property_value, input_prefix: '$' %>
    #
    # Use :field_with_error to have the input be marked as erroneous when an other attribute has an error.
    # e.g., <%= form.govuk_text_field :address_line_two, field_with_error: :address_line_one %>
    #
    %w[text_field file_field text_area].each do |text_input|
      define_method("govuk_#{text_input}") do |attribute, options = {}|
        options[:text_input] = text_input
        options[:class] = input_classes(attribute, options)
        suffix = options.delete(:suffix)
        input_form_group(attribute, options) do
          input_prefix = options[:input_prefix]
          tag_options = options.except(*CUSTOM_OPTIONS)
          tag_options[:id] = attribute
          tag_options[:'aria-describedby'] = aria_describedby(attribute, options)
          tag = __send__(text_input, attribute, tag_options)

          tag = input_prefix ? input_prefix_group(input_prefix) { tag } : tag
          tag = suffix ? suffix_span_tag(suffix) { tag } : tag
        end
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
      hint_html = hint_tag(attribute, options.merge(radio_button_value: value))

      content_tag(:div, class: 'govuk-radios__item') do
        concat_tags(radio_html, label_html, hint_html)
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
    # You can pass an error with the :error parameter.
    # e.g., <%= form.govuk_collection_radio_buttons(:gender, ['f', 'm'], error: 'Please select a gender') %>
    #
    # If you wish to specify the size of the heading and/or which header tag to use, pass a hash into title with text and size:
    # And the default for header tag, if no htag is supplied, is h1
    # <%= form.govuk_collection_radio_buttons(:gender, ['f', 'm'], title: { text: 'What is your gender?', size: :m, htag: :h2 } ) %>
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
          classes << (options[:inline] ? 'govuk-radios--inline' : 'govuk-!-padding-top-2')
          concat_tags(
            hint_and_error_tags(attribute, options),
            content_tag(:div, class: classes.join(' ')) do
              inputs = collection.map do |obj|
                value = value_attr ? obj[value_attr] : obj
                label = label_attr ? obj[label_attr] : nil
                input_attributes = options.dig(:input_attributes, value.to_s) || {}
                govuk_radio_button(attribute, value, options.merge(input_attributes).merge(label: label, collection: true))
              end
              concat_tags(inputs)
            end
          )
        end
      end
    end

    private

    def concat_tags(*tags)
      tags.compact.join.html_safe
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

    def input_classes(attribute, options)
      classes = [options[:class]]
      input_class_type = {
        'text_area' => 'textarea',
        'file_field' => 'file-upload'
      }[options[:text_input]] || 'input'
      classes << "govuk-#{input_class_type}"
      classes << "govuk-#{input_class_type}--error" if error?(attribute, options)
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

    def suffix_span_tag(suffix)
      span_tag = content_tag :span, class: 'input-suffix' do
        " #{suffix}"
      end
      yield + span_tag
    end

    def input_form_group(attribute, options)
      classes = ['govuk-form-group']
      classes << 'govuk-form-group--error' if error?(attribute, options)
      content_tag :div, class: classes.join(' ') do
        concat_tags(label_from_options(attribute, options), hint_and_error_tags(attribute, options), yield)
      end
    end

    def label_from_options(attribute, options)
      return '' if options.key?(:label) && options[:label].nil?

      label_options = text_hash(options.fetch(:label, {}))
      label_classes = ['govuk-label']
      label_classes << "govuk-label--#{label_options[:size]}" if label_options[:size].present?
      label(attribute, label_options[:text], class: label_classes.join(' '), for: attribute)
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
      return if aria_describedby.empty?

      aria_describedby.join(' ')
    end

    # title param can either be:
    # * a text string, e.g  "My title"
    # * a hash, e.g { text: "My title", size: :m, htag: :h2 }
    #
    def fieldset_legend(title)
      title = text_hash(title)
      size = title.fetch(:size, 'xl')
      htag = title.fetch(:htag, :h1)
      content_tag(:legend, class: "govuk-fieldset__legend govuk-fieldset__legend--#{size}") do
        content_tag(htag, title[:text], class: 'govuk-fieldset__heading')
      end
    end

    def text_hash(text)
      text.is_a?(Hash) ? text : { text: text }
    end

    def hint_and_error_tags(attribute, options)
      concat_tags(hint_tag(attribute, options), error_tag(attribute, options))
    end

    def hint?(attribute, options)
      return false if options.key?(:hint) && options[:hint].blank?

      hint_message(attribute, options).present?
    end

    def hint_message(attribute, options)
      return nil if options[:collection]

      options[:hint].presence || I18n.translate("helpers.hint.#{@object_name}.#{attribute}", default: nil)
    end

    def hint_tag(attribute, options)
      return unless hint?(attribute, options)

      classes = ['govuk-hint']
      classes << 'govuk-radios__hint' if options.key?(:radio_button_value)

      id = [attribute, options[:radio_button_value], 'hint'].compact.join('-')
      content_tag(:span, hint_message(attribute, options), class: classes.join(' '), id: id)
    end

    def error_tag(attribute, options)
      return unless error?(attribute, options)

      message = options[:error] || object.errors[attribute].first
      return unless message.present?

      content_tag(:span, class: 'govuk-error-message', id: "#{attribute}-error") do
        content_tag(:span, I18n.translate('helpers.accessibility.error'), class: 'govuk-visually-hidden') + message
      end
    end

    def error?(attribute, options)
      return true if options[:error]

      attr = options[:field_with_error] || attribute
      object.respond_to?(:errors) &&
        errors.messages.key?(attr) &&
        errors.messages[attr].present?
    end
  end
end
